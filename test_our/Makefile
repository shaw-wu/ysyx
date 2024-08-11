VER = verilator --cc --exe --build --trace -j 0
MOUDLE = topp.v
SIMCPP = sim_main.cpp

all:
	htl

htl:
	$(VER) -Wall $(MOUDLE) $(SIMCPP)

