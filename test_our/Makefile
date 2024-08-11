VER = verilator --cc --exe --build --trace -j 0
MOUDLE = topp.v
SIMCPP = sim_main.cpp
VER_FILE = $(MOUDLE)
VER_FILE += $(SIMCPP)

htl:
	$(VER) -Wall $(VER_FILE)
