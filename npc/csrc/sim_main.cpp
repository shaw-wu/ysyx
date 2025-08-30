#include "irom.h"
#include "Vysyx_25010009_top.h"
#include "verilated.h"
#include <stdio.h>
#include <stdlib.h>
#include <assert.h>
#include "verilated_vcd_c.h"
#include <nvboard.h>
#define ENABLE_WAVEFORM

static int sim_time = 500000;
static TOP_NAME* dut;
void nvboard_bind_all_pins(TOP_NAME* top);

VerilatedContext* contextp = NULL; // 上下文变量
VerilatedVcdC* tfp = NULL;         // 波形变量
																	 //
void sim_init(int argc, char** argv ){
	contextp = new VerilatedContext;  
	contextp->commandArgs(argc, argv);
	dut = new Vysyx_25010009_top;                 
	FILE *coe = fopen("/home/shaw/ysyx-workbench/npc/sim/irom/inst.coe", "r");
	assert(coe);
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

static void single_cycle() {
  dut->clk = 0; dut->eval();
  dut->clk = 1; dut->eval();
}

void main_loop(){
	while(contextp->time() < sim_time && !contextp->gotFinish()){
		contextp->timeInc(1);
		single_cycle();
		dut->eval();
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
