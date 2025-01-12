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

BUILD_DIR = $(CURDIR)/build
TOP_MODULE = testbench

# Generate C++ in executable form
VERILATOR_FLAGS += -cc --exe \
									 -Wall \
									 --trace \
									 --timing \
									 --build

# Input files for Verilator
CSRC_DIR = $(CURDIR)/csrc
CSRC = $(wildcard $(CSRC_DIR)/*.c) $(wildcard $(CSRC_DIR)/*.cpp)
VSRC_DIR = $(CURDIR)/vsrc
VSRC = $(wildcard $(VSRC_DIR)/*.v)

######################################################################
default: run

run:
	@echo "-- VERILATE ----------------"
	@echo "Input Verilog sources: $(VSRC)"
	@echo "Input C/C++ sources: $(CSRC)"
	$(VERILATOR) $(VERILATOR_FLAGS) \
		-Mdir $(BUILD_DIR)/obj_dir \
		-top-module $(TOP_MODULE) \
		$(CSRC) $(VSRC)
	@echo "-- BUILD -------------------"
	@if [ -d $(BUILD_DIR)/obj_dir ]; then \
		echo "Running simulation"; \
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
