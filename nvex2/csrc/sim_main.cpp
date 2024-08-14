#include "Vtopp.h"
#include "verilated.h"
#include <stdio.h>
#include <stdlib.h>
#include <assert.h>
#include "verilated_vcd_c.h"
#include <nvboard.h>

static TOP_NAME dut;
void nvboard_bind_all_pins(TOP_NAME* top);

/*
static void single_cycle() {
  dut.clk = 0; dut.eval();
  dut.clk = 1; dut.eval();
}
*/

int main(int argc, char** argv) {
  VerilatedContext* contextp = new VerilatedContext;
  contextp->commandArgs(argc, argv);
  Vtopp* top = new Vtopp{contextp};
  
	nvboard_bind_all_pins(&dut);
	nvboard_init();

 /* VerilatedVcdC* tfp = new VerilatedVcdC;
	contextp->traceEverOn(true);
	top->trace(tfp, 0);
	tfp->open("wave.vcd");
 	*/
//	while (!contextp->gotFinish()) {
	while (1) {
		/*int a = rand() & 1;
		int b = rand() & 1;
		top->a = a;
		top->b = b;
		top->eval();
//		printf("a = %d, b = %d ,f = %d\n", a, b, top->f);
		
		tfp->dump(contextp->time());
		contextp->timeInc(1);

 		assert(top->f == (a ^ b));*/
		//single_cycle();
		dut.eval();
		nvboard_update();
	}
	nvboard_quit();
  delete top;
	//tfp->close();
  delete contextp;
	return 0;
}
