#include "Vtestbench.h"
#include "verilated.h"
#include "verilated_vcd_c.h"
#include <nvboard.h>

#define CONFIG_WAVETRACE
//#define CONFIG_NVBOARD

VerilatedContext* contextp = NULL; // 上下文变量
VerilatedVcdC* tfp = NULL;         // 波形变量
static Vtestbench* top;               // 声明模块变量
static int sim_time = 500000;
static TOP_NAME dut;

//nvboard的clk驱动信号
static void single_cycle() {
	dut.clk = 0; dut.eval();
	dut.clk = 1; dut.eval();
}
//nvboard的reset驱动信号
static void reset(int n){
	dut.rst = 1;
	while (n --> 0) single_cycle();
	sut.rst = 0;
}

void sim_init(int argc, char** argv ){
#ifndef CONFIG_NVBOARD
	contextp = new VerilatedContext;  
	contextp->commandArgs(argc, argv);
	top = new Vtestbench;                 
	#ifdef CONFIG_WAVETRACE
		Verilated::traceEverOn(true);
		tfp = new VerilatedVcdC;
		top->trace(tfp, 99);
		tfp->open("build/dump.vcd");
	#endif
#else
	nvboard_bind_all_pins(&dut);
	nvboard_init();
	reset(10);
#endif
}

void main_loop(){
#ifndef CONFIG_NVBOARD
	while(contextp->time() < sim_time && !contextp->gotFinish()){
		contextp->timeInc(1);
		top->eval();
	#ifdef CONFIG_WAVETRACE
		tfp->dump(contextp->time());
	#endif
	}
#else
	while(1) {
		nvboard_update();
		single_cycle();
	}
#endif
}

void sim_exit(){
#ifdef CONFIG_NVBOARD
	printf("Quit nvboard!\n");
	return;
#endif
#ifdef CONFIG_WAVETRACE
	if(tfp){
		tfp->close();
		delete tfp;
	}
#endif
	delete top;
	delete contextp;
}

int main(int argc, char** argv) {
	sim_init(argc, argv);
	main_loop();
	sim_exit();
	return 0;
}
