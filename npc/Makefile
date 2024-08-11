VPATH = ../test_our
objects_1 = sim_main.cpp topp.v
OBJ = $(wildcard objects_*)
all:
	@echo "Write this Makefile by your self."
	$(OBJ)

sim:
	$(call git_commit, "sim RTL") # DO NOT REMOVE THIS LINE!!!
	@echo "Write this Makefile by your self."
	verilator --cc --exe --build --trace -j 0 -Wall sim_main.cpp topp.v
include ../Makefile
