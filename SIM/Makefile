SIM_DIR     := ${PWD}
RUN_DIR      := ${PWD}/run

TESTNAME     := chaos 
TESTCASE     := ${RUN_DIR}/../../../Nuclei_Compile/hbird-sdk/application/baremetal/accelerator/${TESTNAME}

SIM          := vcs 
DUMPWAVE     := 1
DC_VER       := V3_1
SYN_TAG      := Sysiphus_ssg0p81v0c_tsmc22ull_$(DC_VER)

SOC         := chaos996
CORE        := chaos
CFG         := ${CORE}_config
#acc  1: acc_int16 2: acc_hsmpa
ACC_INT16         := acc_int16
ACC_HSMPA         := acc_hsmpa
T22_NODE          := t22
FLASH       := flash_model
#DDR         := DDR3_PHY
AXI_BUS     := axi_protocol
QSPI_FLASH  := qspi_flash
SDCARD      := sdcard_model   
#isa  soc jtag
TESTMODE    := jtag

CORE_NAME = $(shell echo $(CORE) | tr a-z A-Z)
core_name = $(shell echo $(CORE) | tr A-Z a-z)
#acc_name = $(shell echo $(ACC_INT16) | tr A-Z a-z)
#ddr_name = $(shell echo $(DDR) | tr A-Z a-z)
flash_name = $(shell echo $(FLASH) | tr A-Z a-z)
axi_name = $(shell echo $(AXI_BUS) | tr A-Z a-z)
qspi_name = $(shell echo $(QSPI_FLASH) | tr A-Z a-z)
sdio_name = $(shell echo $(SDCARD) | tr A-Z a-z)

test_mode = $(shell echo $(TESTMODE) | tr A-Z a-z)
plat = t22

all: run_test

install:
	mkdir -p ${SIM_DIR}/install/TB
ifeq (${test_mode},isa)
	cp ${SIM_DIR}/../TB/chaos_soc_isa_tb.v ${SIM_DIR}/install/TB/chaos_soc_tb.v -rf
else ifeq (${test_mode},jtag)
	cp ${SIM_DIR}/../TB/chaos_jtag_tb.v ${SIM_DIR}/install/TB/chaos_soc_tb.v -rf
else
	cp ${SIM_DIR}/../TB/chaos_soc_tb.v ${SIM_DIR}/install/TB/chaos_soc_tb.v -rf	
endif
	cp ${SIM_DIR}/../RTL ${SIM_DIR}/install -rf
 
install_dc:
	mkdir -p ${SIM_DIR}/install/tb
	#mkdir -p ${SIM_DIR}/install/rtl/${acc_name}
	mkdir -p ${SIM_DIR}/install/rtl/core
	mkdir -p ${SIM_DIR}/install/rtl/acc
	mkdir -p ${SIM_DIR}/install/rtl/soc
	mkdir -p ${SIM_DIR}/install/sdf
	mkdir -p ${SIM_DIR}/install/rtl/${axi_name}/include
	mkdir -p ${SIM_DIR}/install/rtl/${axi_name}/src/apb_to_axi_lite
	cp ${SIM_DIR}/../tb/dc_tb/*.v ${SIM_DIR}/install/tb -rf
	cp ${SIM_DIR}/../syn/${SYN_TAG}/results/*.mapped.v  ${SIM_DIR}/install/rtl/soc -rf
	cp ${SIM_DIR}/../syn/${SYN_TAG}/results/*.mapped.sdf ${SIM_DIR}/install/sdf -rf
	cp ${SIM_DIR}/../rtl/${core_name}/core/e203_defines.v ${SIM_DIR}/install/rtl/core/e203_defines.v -rf
	cp ${SIM_DIR}/../rtl/${core_name}/core/config.v ${SIM_DIR}/install/rtl/core/config.v -rf	
	cp ${SIM_DIR}/../rtl/${core_name}/soc/uart_rx_print.v ${SIM_DIR}/install/rtl/soc/uart_rx_print.v -rf
	cp ${SIM_DIR}/../rtl/${axi_name}/include ${SIM_DIR}/install/rtl/${axi_name} -rf	
	cp ${SIM_DIR}/../rtl/${axi_name}/src/apb_to_axi_lite ${SIM_DIR}/install/rtl/${axi_name}/src -rf	
	cp ${SIM_DIR}/../rtl/${axi_name}/src/axil_adapter.v ${SIM_DIR}/install/rtl/${axi_name}/src/axil_adapter.v
	cp ${SIM_DIR}/../rtl/${axi_name}/src/axil_adapter_rd.v ${SIM_DIR}/install/rtl/${axi_name}/src/axil_adapter_rd.v
	cp ${SIM_DIR}/../rtl/${axi_name}/src/axil_adapter_wr.v ${SIM_DIR}/install/rtl/${axi_name}/src/axil_adapter_wr.v	
	cp ${SIM_DIR}/../rtl/${axi_name}/src/pulse_cdc.sv ${SIM_DIR}/install/rtl/${axi_name}/src/pulse_cdc.sv		
	cp ${SIM_DIR}/../rtl/${flash_name} ${SIM_DIR}/install/rtl -rf	
	cp ${SIM_DIR}/../rtl/${acc_name}/Perip ${SIM_DIR}/install/rtl/acc/Perip -rf
ifeq (${acc_name},${ACC_INT16})
	sed -i 's|//`define ACC_INT16|`define ACC_INT16|' ./install/rtl/core/e203_defines.v
else ifeq (${acc_name},${ACC_HSMPA})
	cp ${SIM_DIR}/../rtl/${acc_name}/CNN_defines.vh ${SIM_DIR}/install/rtl/acc/CNN_defines.vh -rf	
	sed -i 's|//`define ACC_HSMPA|`define ACC_HSMPA|' ./install/rtl/core/e203_defines.v
endif 
	cp ${SIM_DIR}/../rtl/T22_Lib ${SIM_DIR}/install/rtl -rf
ifeq (${plat},${T22_NODE})
	sed -i 's|//`define T22NM|`define T22NM|' ./install/rtl/acc/CNN_defines.vh
	sed -i 's|//`define T22NM|`define T22NM|' ./install/rtl/core/e203_defines.v
endif 

${RUN_DIR}:
	mkdir -p ${RUN_DIR}
	rm -f ${RUN_DIR}/Makefile
	ln -s ${SIM_DIR}/bin/run.makefile ${RUN_DIR}/Makefile

compile: ${RUN_DIR}
	make compile RUN_DIR=${RUN_DIR} SIM_TOOL=${SIM} -C ${RUN_DIR}

wave: ${RUN_DIR}
	make wave TESTCASE=${TESTCASE} SIM_TOOL=${SIM} RUN_DIR=${RUN_DIR} -C ${RUN_DIR}

run_test: compile
	make run DUMPWAVE=${DUMPWAVE} TESTCASE=${TESTCASE} SIM_TOOL=${SIM} RUN_DIR=${RUN_DIR} -C ${RUN_DIR}

SELF_TESTS := $(patsubst %.dump,%,$(wildcard ${RUN_DIR}/../../riscv-tools/riscv-tests/isa/generated/rv32uc-p*.dump))
ifeq ($(core_name),${E203})
SELF_TESTS += $(patsubst %.dump,%,$(wildcard ${RUN_DIR}/../../riscv-tools/riscv-tests/isa/generated/rv32um-p*.dump))
SELF_TESTS += $(patsubst %.dump,%,$(wildcard ${RUN_DIR}/../../riscv-tools/riscv-tests/isa/generated/rv32ua-p*.dump))
endif

SELF_TESTS += $(patsubst %.dump,%,$(wildcard ${RUN_DIR}/../../riscv-tools/riscv-tests/isa/generated/rv32ui-p*.dump))
SELF_TESTS += $(patsubst %.dump,%,$(wildcard ${RUN_DIR}/../../riscv-tools/riscv-tests/isa/generated/rv32mi-p*.dump))

regress_prepare:
	make compile
	@-rm -rf ${RUN_DIR}/rv32*.log
regress_run:
	$(foreach tst,$(SELF_TESTS), make run_test DUMPWAVE=0 TESTCASE=$(tst);)
regress_collect:
	@-rm -rf ${RUN_DIR}/regress.res
	@find ${RUN_DIR} -name "rv32*.log" -exec bin/find_test_fail.csh {} >> ${RUN_DIR}/regress.res \;
	@cat ${RUN_DIR}/regress.res
regress: regress_prepare regress_run regress_collect 

clean:
	rm -rf run
	rm -rf install

.PHONY: compile run install clean all run_test regress regress_prepare regress_run regress_collect 

