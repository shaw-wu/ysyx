# Check for sanity to avoid later confusion
ifneq ($(words $(CURDIR)),1)
 $(error Unsupported: GNU Make cannot build in directories containing spaces, build elsewhere: '$(CURDIR)')
endif

# Set up variables
ifeq ($(VERILATOR_ROOT),)
VERILATOR = verilator
else
export VERILATOR_ROOT
VERILATOR = $(VERILATOR_ROOT)/bin/verilator
endif


######################################################################

#配置选项
TOP_NAME = top
NXDC_FILE = $(shell pwd)/constr/top.nxdc
SIM_TIME ?= 50000000
ENABLE_WAVEFORM ?= 1

#目录
BUILD_DIR = $(CURDIR)/build
CSRC_DIR = $(CURDIR)/csrc
VSRC_DIR = $(CURDIR)/vsrc

#编译与配置标志
VERILATOR_FLAGS += -cc --exe \
									 -Wall \
									 --trace \
									 --timing \
									 --build
CXXFLAGS += -DSIM_TIME=$(SIM_TIME)
ifeq ($(ENABLE_WAVEFORM), 1)
#CXXFLAGS += -DENABLE_WAVEFORM -I/home/shaw/ysyx/nvboard/include/
endif

SRC_AUTO_BIND = $(abspath $(BUILD_DIR)/auto_bind.cpp)
$(SRC_AUTO_BIND): $(NXDC_FILE)
	python3 $(NVBOARD_HOME)/scripts/auto_pin_bind.py $^ $@

#源文件
CSRC = $(wildcard $(CSRC_DIR)/*.c) $(wildcard $(CSRC_DIR)/*.cpp)
CSRC += $(SRC_AUTO_BIND)
VSRC = $(wildcard $(VSRC_DIR)/*.v)
include $(NVBOARD_HOME)/scripts/nvboard.mk

INCFLAGS = $(addprefix -I, $(INC_PATH))
CXXFLAGS = $(INCFLAGS) -DTOP_NAME="\"V$(TOP_NAME)\""


######################################################################
default: run


run:
	$(call git_commit, "sim RTL") # DO NOT REMOVE THIS LINE!!!
	@echo "-- VERILATE ----------------"
	@echo "Input Verilog sources: $(VSRC)"
	@echo "Input C/C++ sources: $(CSRC)"
	$(VERILATOR) $(VERILATOR_FLAGS) \
		-Mdir $(BUILD_DIR)/obj_dir \
		-top-module $(TOP_NAME) \
		$(CSRC) $(VSRC) \
		$(addprefix -CFLAGS , $(CXXFLAGS)) $(addprefix -LDFLAGS , $(LDFLAGS)) 
	@echo "-- BUILD -------------------"
	@if [ -d $(BUILD_DIR)/obj_dir ]; then \
		echo "Running simulation at $(BUILD_DIR)/obj_dir"; \
		ls -l $(BUILD_DIR)/obj_dir/"V$(TOP_MODULE)"; \
		$(BUILD_DIR)/obj_dir/"V$(TOP_MODULE)"; \
		echo "--  RUN  -------------------"; \
	fi

wave:
	@if [ -f $(BUILD_DIR)/dump.vcd ]; then \
		echo "Check wave"; \
		gtkwave $(BUILD_DIR)/dump.vcd; \
		echo "--  RUN  -------------------"; \
	else \
		echo "No dump.vcd found!"; \
	fi


######################################################################
# Other targets

clean :
	@if [ -d $(BUILD_DIR) ]; then \
		echo "Cleaning build directory."; \
		rm -rf $(BUILD_DIR); \
	fi
	@mkdir -p $(BUILD_DIR)
#include ~/ysyx-workbench/Makefile
