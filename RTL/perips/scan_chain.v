`include "../core/defines.v"

module scan_chain_ctrl (
    input wire clk,
    input wire rstn,
    input wire [`RegAddrBus] sc_addr_i, // JTAG模块读、写寄存器的地址
    input wire [`RegBus] sc_data_i,     // JTAG模块写寄存器数据
    input wire sc_we_i,                 // JTAG模块写寄存器标志
    output reg [`RegBus] sc_data_o,     // JTAG模块读取到的寄存器数据
    output reg scan_in,                       // Scan chain input controlled by JTAG
    input wire scan_out,                      // Scan chain output read by JTAG
    output reg scan_en,                       // Scan chain enable controlled by JTAG
    output reg scan_rst                       // Scan chain reset controlled by JTAG
);
	parameter SCAN_CHAIN_LENGTH = 1024;
    // Define the JTAG register address mapping
    localparam SCAN_IN_ADDR  =  'h0;  // Address to control scan_in signal
    localparam SCAN_OUT_ADDR =  'h4;  // Address to read scan_out signal
    localparam SCAN_EN_ADDR  =  'h8;  // Address to control scan_en signal
    localparam SCAN_RST_ADDR =  'hc;  // 
    localparam SCAN_DONE_ADDR = 'h10;  // 
	localparam SCAN_RDCNT_ADDR = 'h14; //
	localparam SCAN_WRCNT_ADDR = 'h18; //
	localparam SCAN_MODE =  'h1C;      //
    // Register to temporarily hold scan_out data for reading
    reg scan_out_reg;
	reg scan_done;
    // Counter for scan chain addressing
    reg [$clog2(SCAN_CHAIN_LENGTH)-1:0] scan_counter;

	reg [`RegBus] scan_rdcnt_addr;
	reg [`RegBus] scan_wrcnt_addr;
	    // State Encoding
    typedef enum reg [1:0] {
        STATE_IDLE     = 2'b00, // Idle state
        STATE_PROCESS  = 2'b01, // Processing state
        STATE_DONE     = 2'b10  // Done state
    } state_t;

    // State variables
    reg [1:0] current_state, next_state;
	reg scan_in_reg;
	reg scan_enable;
	reg scan_out_reg;
	reg [1:0] scan_mode; // 2'b1 write      1'b1 : read
	wire scan_rd;
	wire scan_wr;
	reg scan_start;
	assign scan_wr = scan_mode[1];
	assign scan_rd = scan_mode[0];
    // write operation: control scan_in, scan_en, scan_rst signals
    always @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            scan_in_reg <= 1'b0;
            scan_enable <= 1'b0;
            scan_rst <= 1'b0;
			scan_start <= 1'b0;
			scan_rdcnt_addr<= 'd0;
			scan_wrcnt_addr<= 'd0;			
			scan_mode <= 'd0;
		end else begin
			if (sc_we_i) begin
				case (sc_addr_i)
					SCAN_IN_ADDR: begin
						// Write to scan_in signal
						scan_in_reg <= sc_data_i[0];
					end
					SCAN_EN_ADDR: begin
						// Write to scan_start signal
						scan_start <= sc_data_i[0];
					end
					SCAN_RST_ADDR: begin
						// Write to scan_rst signal
						scan_rst <= sc_data_i[0];
					end
					SCAN_RDCNT_ADDR: begin
						scan_rdcnt_addr <= sc_data_i;
					end
					SCAN_WRCNT_ADDR: begin
						scan_wrcnt_addr <= sc_data_i;
					end			
					SCAN_MODE: begin
						scan_mode <= sc_data_i[1:0];
					end		
					default: begin
						// Do nothing for other addresses
					end
				endcase
			end 
			else begin
				scan_start <= 1'b0;
			end

   	 	end
	end

		// read operation: read scan_out data or other status
    always @(*) begin
        case (sc_addr_i)
            SCAN_IN_ADDR: begin
                sc_data_o = {31'd0, scan_in_reg};
            end
            SCAN_OUT_ADDR: begin
                sc_data_o = {31'd0, scan_out_reg};
            end
            SCAN_EN_ADDR: begin
                sc_data_o = {31'd0, scan_enable};
            end
            SCAN_RST_ADDR: begin
                sc_data_o = {31'd0, scan_rst};
            end
			SCAN_DONE_ADDR: begin
                sc_data_o = {31'd0, scan_done};
			end
			SCAN_MODE: begin
                sc_data_o = {30'd0, scan_mode};
			end
            default: begin
                sc_data_o = 'b0; // Default zero for undefined addresses
            end
        endcase
    end

 // State transition
    always @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            current_state <= STATE_IDLE; // Reset to initial state
        end else begin
            current_state <= next_state; // Transition to next state
        end
    end

    // Next state logic
    always @(*) begin
        // Default assignment
        next_state = current_state;

        case (current_state)
            STATE_IDLE: begin
                if (scan_start) begin
					scan_enable = 1'b1;
                    next_state = STATE_PROCESS; // Transition to PROCESS state
                end
            end
            STATE_PROCESS: begin
                if (scan_done == 1'b1) begin
					scan_enable = 1'b0;
                    next_state = STATE_DONE; // Transition to DONE state
                end
            end
            STATE_DONE: begin
                // Example: stay in DONE state or transition back to IDLE
                next_state = STATE_IDLE; // Transition back to IDLE
            end
            default: begin
                next_state = STATE_IDLE; // Default to IDLE on unknown state
            end
        endcase
    end

    always @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            scan_counter <= 'd0;
			scan_done <= 1'b0;
        end else begin
			if (scan_enable) begin
				// Increment counter to track the current position
				if (scan_counter < SCAN_CHAIN_LENGTH - 1)
				begin
					scan_counter <= scan_counter + 1;
					scan_done <= 1'b0;
				end
				else
				begin
					scan_counter <= 0;  //1-round finished
					scan_done <= 1'b1;
				end
			end 
        end
    end

   // Write data to the scan chain using JTAG: load bit when the counter matches
    always @(*) begin
        if (scan_enable) begin
		    if(scan_counter == SCAN_CHAIN_LENGTH - scan_wrcnt_addr) begin
            // When the counter matches the address, write data to the scan chain
            	scan_in <= scan_in_reg; // Write at the input side
			end 
			else
				scan_in <= scan_out;
		end
    end

    // Read data from the scan chain using JTAG: capture scan_out when counter matches
    always @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            scan_out_reg <= 'd0;
		end
        else if (scan_counter == SCAN_CHAIN_LENGTH - scan_rdcnt_addr) begin
            scan_out_reg <= scan_out;
     	end 
    end

    // Read data from the scan chain using JTAG: capture scan_out when counter matches
    always @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            scan_en <= 'd0;
		end
        else
            scan_en <= scan_enable;	 
    end




endmodule

//this is a virtual scan chain.   Real scan chain is generated by tools corresponding to platforms the user adopt.
module scan_chain (
    input wire clk,
    input wire scan_rst,                      // Scan chain reset controlled by JTAG
    input wire scan_en,                       // Scan chain enable controlled by JTAG
    input wire scan_in,                       // Scan chain input controlled by JTAG
    output wire scan_out                      // Scan chain output read by JTAG
);

    // Define the length of the scan chain
    parameter SCAN_CHAIN_LENGTH = 1024;

    // Internal scan chain register array, initialized to 0
    reg [SCAN_CHAIN_LENGTH-1:0] scan_chain;

	//always @ (posedge clk)
	//begin
	assign	scan_out = scan_chain[SCAN_CHAIN_LENGTH-1];
	//end

    // Scan chain output is the last bit of the scan_chain register
    //assign scan_out = scan_chain[SCAN_CHAIN_LENGTH-1];

    // Scan chain operation
    always @(posedge clk or posedge scan_rst) begin
        if (scan_rst) begin
            // Reset the entire scan chain to 0
            scan_chain <= {SCAN_CHAIN_LENGTH{1'b0}};
        end else if (scan_en) begin
            // Shift the scan chain when scan_en is active
            scan_chain <= {scan_chain[SCAN_CHAIN_LENGTH-2:0], scan_in};
        end
    end

endmodule
