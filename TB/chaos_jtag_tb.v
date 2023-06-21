`timescale 1 ns / 1 ps

`include "defines.v"

`define TEST_PROG  1
`define TEST_JTAG  1


// testbench module
module chaos_soc_tb;

    reg clk;
    reg rst;

    always #10 clk = ~clk;     // 50MHz

    wire[`RegBus] x3 = tinyriscv_soc_top_0.u_tinyriscv.u_regs.regs[3];
    wire[`RegBus] x26 = tinyriscv_soc_top_0.u_tinyriscv.u_regs.regs[26];
    wire[`RegBus] x27 = tinyriscv_soc_top_0.u_tinyriscv.u_regs.regs[27];

    integer r;

`ifdef TEST_JTAG
  wire jtag_TDI;
  wire jtag_TDO;
  wire jtag_TCK;
  wire jtag_TMS;
  wire jtag_TRSTn;

    integer i;
    reg[39:0] shift_reg;
    reg in;
    wire[39:0] req_data = tinyriscv_soc_top_0.u_jtag_top.u_jtag_driver.dtm_req_data;
    wire[4:0] ir_reg    = tinyriscv_soc_top_0.u_jtag_top.u_jtag_driver.ir_reg;
    wire dtm_req_valid  = tinyriscv_soc_top_0.u_jtag_top.u_jtag_driver.dtm_req_valid;
    wire[31:0] dmstatus = tinyriscv_soc_top_0.u_jtag_top.u_jtag_dm.dmstatus;
  jtagdpi jtagdpi(
  .clk_i(clk),
  .rst_ni(rst),

  .jtag_tck(jtag_TCK),
  .jtag_tms(jtag_TMS),
  .jtag_tdi(jtag_TDI),
  .jtag_tdo(jtag_TDO),
  .jtag_trst_n(jtag_TRSTn),
  .jtag_srst_n()
  );
`else
    wire jtag_TDI = 1'b0;
    wire jtag_TDO;
    wire jtag_TCK = 1'b0; 
    wire jtag_TMS = 1'b0;
    wire jtag_TRSTn = 1'b1;
`endif

    initial begin
        clk = 0;
        rst = `RstEnable;
        $display("test running...");
        #40
        rst = `RstDisable;
        #200

`ifdef TEST_PROG
        wait(x26 == 32'b1)   // wait sim end, when x26 == 1
        #100
        if (x27 == 32'b1) begin
            $display("~~~~~~~~~~~~~~~~~~~ TEST_PASS ~~~~~~~~~~~~~~~~~~~");
            $display("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~");
            $display("~~~~~~~~~ #####     ##     ####    #### ~~~~~~~~~");
            $display("~~~~~~~~~ #    #   #  #   #       #     ~~~~~~~~~");
            $display("~~~~~~~~~ #    #  #    #   ####    #### ~~~~~~~~~");
            $display("~~~~~~~~~ #####   ######       #       #~~~~~~~~~");
            $display("~~~~~~~~~ #       #    #  #    #  #    #~~~~~~~~~");
            $display("~~~~~~~~~ #       #    #   ####    #### ~~~~~~~~~");
            $display("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~");
        end else begin
            $display("~~~~~~~~~~~~~~~~~~~ TEST_FAIL ~~~~~~~~~~~~~~~~~~~~");
            $display("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~");
            $display("~~~~~~~~~~######    ##       #    #     ~~~~~~~~~~");
            $display("~~~~~~~~~~#        #  #      #    #     ~~~~~~~~~~");
            $display("~~~~~~~~~~#####   #    #     #    #     ~~~~~~~~~~");
            $display("~~~~~~~~~~#       ######     #    #     ~~~~~~~~~~");
            $display("~~~~~~~~~~#       #    #     #    #     ~~~~~~~~~~");
            $display("~~~~~~~~~~#       #    #     #    ######~~~~~~~~~~");
            $display("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~");
            $display("fail testnum = %2d", x3);
            for (r = 0; r < 32; r = r + 1)
                $display("x%2d = 0x%x", r, tinyriscv_soc_top_0.u_tinyriscv.u_regs.regs[r]);
        end
`endif
        //$finish;
    end

    // sim timeout
    initial begin
        //while (1)
        //begin
        //end 
        $display("Time Out.");
        //$finish;
    end

    // read mem data
    reg[7:0] rom [0 : `RomNum*4-1];
    //reg[`MemBus] _rom[0:`RomNum - 1]; 
    integer i;
    initial begin
        for (i=0;i<(`RomNum*4);i=i+1) begin
            rom[i] = 'd0;
        end

        $readmemh ("../../../Ccode/uart_tx.verilog" , rom);

        #1
        for (i=0;i<(`RomNum);i=i+1) begin
            tinyriscv_soc_top_0.u_rom._rom[i] = {
                                     rom[i*4+3],
                                     rom[i*4+2],
                                     rom[i*4+1],
                                     rom[i*4+0]};
        end
    end
  integer dumpwave;
    // generate wave file, used by verdi
  initial begin
    if($value$plusargs("DUMPWAVE=%d",dumpwave)) begin
      if(dumpwave != 0) begin
	 `ifdef vcs
            $display("VCS used");
            $fsdbDumpfile("chaos_soc_tb.fsdb");
            $fsdbDumpvars(0, chaos_soc_tb, "+mda");
         `endif

	 `ifdef iverilog
            $display("iverlog used");
	          $dumpfile("chaos_soc_tb.vcd");
            $dumpvars(0, chaos_soc_tb);
         `endif
      end
    end
  end

wire uart_tx_pin;
    tinyriscv_soc_top tinyriscv_soc_top_0(
        .clk(clk),
        .rst(rst),
        .uart_debug_pin(1'b0),
        .uart_tx_pin(uart_tx_pin)
`ifdef TEST_JTAG
        ,
        .jtag_TCK(jtag_TCK),
        .jtag_TMS(jtag_TMS),
        .jtag_TDI(jtag_TDI),
        .jtag_TDO(jtag_TDO)
`endif
    );

wire uart_rxd = uart_tx_pin;

uart_rx_print #
(
	.CLK_FREQ(50000000)
) u_uart_rx_print
(
  .sys_clk(clk),
  .sys_rst_n(rst),
  .uart_rxd(uart_rxd),
  .uart_done(),
  .uart_data()
);

endmodule
