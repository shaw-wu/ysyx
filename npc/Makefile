TOP_NAME = ysyxSoCFull
#NXDC_FILE = $(shell pwd)/constr/top.nxdc
#INC_PATH = $(shell pwd)/sim/include
INC_PATH += $(shell pwd)/include
#INC_PATH += $(shell pwd)/include/memory
VERILATOR_INC_PATH = $(shell pwd)/vsrc/uart16550/rtl
VERILATOR_INC_PATH += $(shell pwd)/vsrc/spi/rtl
#INC_PATH += $(shell pwd)/include/device
#LINC_PATH += /usr/include/readline
LIBS ?=

#CONFIG_ITRACE = y
#CONFIG_DIFFTEST = y

GUEST_ISA = riscv32
VERILATOR = verilator
#MACROS_FLAGS ?=
#MACROS_FLAGS += -DMONITOR_EN=""
#MACROS_FLAGS += -DCONFIG_IRINGBUF=""
#MACROS_FLAGS += -DCONFIG_DIFFTEST=""
#MACROS_FLAGS += -DCONFIG_ITRACE=""
#MACROS_FLAGS += -DCONFIG_MTRACE=""
#MACROS_FLAGS += -DCONFIG_FTRACE=""
#MACROS_FLAGS += -DCONFIG_ISA_riscv=""
#MACROS_FLAGS += -DCONFIG_RVE=1
#MACROS_FLAGS += -DCONFIG_PC_RESET_OFFSET=0x00
#MACROS_FLAGS += -D__GUEST_ISA__="$(GUEST_ISA)"
#MACROS_FLAGS += -DCONFIG_WATCHPOINT=""
VERILATOR_CFLAGS += --cc --build --trace --timescale "1ns/1ns" --no-timing
VERILATOR_CFLAGS += $(addprefix -I, $(VERILATOR_INC_PATH))
#-MMD --build --cc 
									#-03 --x-assign fast --x-initial --noassert

ARGS ?=
BUILD_DIR = $(shell pwd)/build
OBJ_DIR = $(BUILD_DIR)/obj_dir
BIN = $(BUILD_DIR)/$(TOP_NAME)
INC_PATH += $(OBJ_DIR)

SRC_AUTO_BIND = $(abspath $(BUILD_DIR)/auto_bind.cpp)
$(SRC_AUTO_BIND): $(NXDC_FILE)
	python3 $(NVBOARD_HOME)/scripts/auto_pin_bind.py $^ $@

CSRCS ?=
CXXFLAGS ?=
include $(NPC_HOME)/csrc/utils/filelist.mk
VSRCS = $(shell find $(abspath ./vsrc) -name "*.v")
VSRCS += $(shell find $(abspath ./vsrc/amba) -name "*.v")
VSRCS += $(shell find $(abspath ./vsrc/bitrev) -name "*.v")
VSRCS += $(shell find $(abspath ./vsrc/core) -name "*.v")
VSRCS += $(shell find $(abspath ./vsrc/flash) -name "*.v")
VSRCS += $(shell find $(abspath ./vsrc/gpio) -name "*.v")
VSRCS += $(shell find $(abspath ./vsrc/ps2) -name "*.v")
VSRCS += $(shell find $(abspath ./vsrc/psram) -name "*.v")
VSRCS += $(shell find $(abspath ./vsrc/sdram) -name "*.v")
VSRCS += $(shell find $(abspath ./vsrc/spi/rtl) -name "*.v")
VSRCS += $(shell find $(abspath ./vsrc/uart16550/rtl) -name "*.v")
VSRCS += $(shell find $(abspath ./vsrc/vga) -name "*.v")
CSRCS += $(shell find $(abspath ./csrc) -name "*.cpp")
#CSRCS += $(shell find $(abspath ./csrc) -name "*.c")
#CSRCS += $(shell find $(abspath ./csrc/sdb) -name "*.c")
#CSRCS += $(shell find $(abspath ./csrc/ftrace) -name "*.c")
#CSRCS += $(shell find $(abspath ./csrc/memory) -name "*.c")
#CSRCS += $(shell find $(abspath ./csrc/difftest) -name "*.c")
#CSRCS += $(shell find $(abspath ./csrc/isa-difftest) -name "*.c")
#CSRCS += $(shell find $(abspath ./sim) -name "*.cpp")
#CSRCS += $(SRC_AUTO_BIND)
include $(NVBOARD_HOME)/scripts/nvboard.mk

INCFLAGS = $(addprefix -I, $(INC_PATH))
CXXFLAGS += $(INCFLAGS) -DTOP_NAME="\"V$(TOP_NAME)\""
CXXFLAGS += $(MACROS_FLAGS)
CXXFLAGS += -U__STDC_FORMAT_MACROS

IMG ?=
ELF ?=
DIFF_REF_SO ?=

LDFLAGS += $(addprefix -L, $(LINC_PATH)) $(addprefix -l, readline) $(LIBS)

#ifdef CONFIG_DIFFTEST
include $(NPC_HOME)/csrc/difftest/difftest.mk
#endif
ARGS += $(ARGS_DIFF)

$(BIN): $(VSRCS) $(CSRCS) $(NVBOARD_ARCHIVE)
	@rm -rf $(OBJ_DIR)
	$(VERILATOR) $(VERILATOR_CFLAGS) \
		--top-module $(TOP_NAME) $^ \
		$(addprefix -CFLAGS , $(CXXFLAGS)) $(addprefix -LDFLAGS , $(LDFLAGS)) \
		--Mdir $(OBJ_DIR) --exe -o $(abspath $(BIN))

all: default

compile:$(BIN)
	@echo $(info # compile $(BIN))
	
sim:$(BIN)
	$(call git_commit, "sim RTL") # DO NOT REMOVE THIS LINE!!!
	@$^ $(IMG) $(ELF) $(DIFF_REF_SO)
cleansim:
	@rm -rf $(BUILD_DIR)
	@mkdir $(BUILD_DIR)
wave:
	@gtkwave $(BUILD_DIR)/dump.vcd
.PHONY: default all sim clean_bd
include ../Makefile
