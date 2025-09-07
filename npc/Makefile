TOP_NAME = ysyx_25010009_top
NXDC_FILE = $(shell pwd)/constr/top.nxdc
INC_PATH = $(shell pwd)/sim/include
INC_PATH += $(shell pwd)/include
INC_PATH += $(shell pwd)/include/memory
#INC_PATH += $(shell pwd)/include/device
LINC_PATH += /usr/include/readline
LIBS ?=

CONFIG_ITRACE = y

VERILATOR = verilator
MACROS_FLAGS ?=
#MACROS_FLAGS += -DMONITOR_EN=""
MACROS_FLAGS += -DCONFIG_IRINGBUF=""
MACROS_FLAGS += -DCONFIG_ITRACE=""
MACROS_FLAGS += -DCONFIG_FTRACE=""
MACROS_FLAGS += -DCONFIG_ISA_riscv=""
#MACROS_FLAGS += -DCONFIG_WATCHPOINT=""
VERILATOR_CFLAGS += --cc --build --trace
#-MMD --build --cc 
									#-03 --x-assign fast --x-initial --noassert

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
CSRCS += $(shell find $(abspath ./csrc) -name "*.cpp")
CSRCS += $(shell find $(abspath ./csrc/sdb) -name "*.c")
CSRCS += $(shell find $(abspath ./csrc/ftrace) -name "*.c")
CSRCS += $(shell find $(abspath ./csrc/memory) -name "*.c")
CSRCS += $(shell find $(abspath ./sim/irom) -name "*.cpp")
CSRCS += $(shell find $(abspath ./sim) -name "*.cpp")
CSRCS += $(SRC_AUTO_BIND)
include $(NVBOARD_HOME)/scripts/nvboard.mk

INCFLAGS = $(addprefix -I, $(INC_PATH))
CXXFLAGS += $(INCFLAGS) -DTOP_NAME="\"V$(TOP_NAME)\""
CXXFLAGS += $(MACROS_FLAGS)
CXXFLAGS += -U__STDC_FORMAT_MACROS


IMG ?=
ELF ?=
DIFF_REF_SO ?=

LDFLAGS += $(addprefix -L, $(LINC_PATH)) $(addprefix -l, readline) $(LIBS)

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
