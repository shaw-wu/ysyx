#include "irom.h"
#include "Vysyx_25010009_top.h"
#include "verilated.h"
#include <stdio.h>
#include <stdlib.h>
#include <assert.h>
#include "verilated_vcd_c.h"
#include <nvboard.h>
#define ENABLE_WAVEFORM
#define RESET_TIME 10

static int sim_time = 500000;
static TOP_NAME* dut;
void nvboard_bind_all_pins(TOP_NAME* top);

VerilatedContext* contextp = NULL; // 上下文变量
VerilatedVcdC* tfp = NULL;         // 波形变量
																	 //
static void single_cycle() {
  dut->clk = ~dut->clk & 1; dut->eval();
}

void sim_init(int argc, char** argv ){
	contextp = new VerilatedContext;  
	contextp->commandArgs(argc, argv);
	dut = new Vysyx_25010009_top;                 
	dut->clk = 0;
	dut->rst = 1;

	FILE *coe = fopen("/home/shaw/ysyx-workbench/npc/sim/irom/inst.coe", "r");
	load_rom(coe);
	fclose(coe);

	#ifdef ENABLE_WAVEFORM
		Verilated::traceEverOn(true);
		tfp = new VerilatedVcdC;
		dut->trace(tfp, 99);
		tfp->open("build/dump.vcd");
	#endif
	#ifdef ENABLE_NVBOARD
	nvboard_bind_all_pins(dut);
	nvboard_init();
	#endif

}

void main_loop(){
	int i = 0;
	while(contextp->time() < sim_time && !contextp->gotFinish()){
		contextp->timeInc(1);
		single_cycle();
		if(i < RESET_TIME) i++;
		if(i == RESET_TIME) dut->rst = 0;
	#ifdef ENABLE_WAVEFORM
		tfp->dump(contextp->time());
	#endif
	#ifdef ENABLE_NVBOARD
		nvboard_update();
	#endif
	}
}

void sim_exit(){
#ifdef ENABLE_WAVEFORM
	if(tfp){
		tfp->close();
		delete tfp;
	}
#endif
#ifdef ENABLE_NVBOARD
	nvboard_quit();
#endif
	delete dut;
	delete contextp;
}

int main(int argc, char** argv) {
	sim_init(argc, argv);
	main_loop();
	sim_exit();
	return 0;
}
