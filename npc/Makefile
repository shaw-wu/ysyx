TOP_NAME = ysyx_25010009_top
NXDC_FILE = $(shell pwd)/constr/top.nxdc
INC_PATH = $(shell pwd)/sim/include

VERILATOR = verilator
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

VSRCS = $(shell find $(abspath ./vsrc) -name "*.v")
CSRCS = $(shell find $(abspath ./csrc) -name "*.cpp")
CSRCS += $(shell find $(abspath ./sim/irom) -name "*.cpp")
CSRCS += $(SRC_AUTO_BIND)
include $(NVBOARD_HOME)/scripts/nvboard.mk

INCFLAGS = $(addprefix -I, $(INC_PATH))
CXXFLAGS = $(INCFLAGS) -DTOP_NAME="\"V$(TOP_NAME)\""

$(BIN): $(VSRCS) $(CSRCS) $(NVBOARD_ARCHIVE)
	@rm -rf $(OBJ_DIR)
	$(VERILATOR) $(VERILATOR_CFLAGS) \
		--top-module $(TOP_NAME) $^ \
		$(addprefix -CFLAGS , $(CXXFLAGS)) $(addprefix -LDFLAGS , $(LDFLAGS)) \
		--Mdir $(OBJ_DIR) --exe -o $(abspath $(BIN))

all: default

sim:$(BIN)
	$(call git_commit, "sim RTL") # DO NOT REMOVE THIS LINE!!!
	@$^
cleansim:
	@rm -rf $(BUILD_DIR)
	@mkdir $(BUILD_DIR)
wave:
	@gtkwave $(BUILD_DIR)/dump.vcd
.PHONY: default all sim clean_bd
include ../Makefile
