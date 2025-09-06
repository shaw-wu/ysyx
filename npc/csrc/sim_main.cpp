#include <Vysyx_25010009_top__Dpi.h>
#include "irom.h"
#include <paddr.h>
#include "Vysyx_25010009_top.h"
#include "verilated.h"
#include <stdio.h>
#include <stdlib.h>
#include <assert.h>
#include "verilated_vcd_c.h"
#include <nvboard.h>
#include <ebreak.h>
#include <sdb.h>
#include <utils.h>
#define ENABLE_WAVEFORM
#define RESET_TIME 10
#define MONITOR_EN

#define STRIP_TO_CSRC(file) (strstr(file, "csrc/") ? strstr(file, "csrc/") : file)

int execed_once(int speec);

static int sim_time = 5000;
static TOP_NAME* dut;
void nvboard_bind_all_pins(TOP_NAME* top);
int end_sim = 0;
int stop_sim = 0;
bool is_good_trap = false;
uint32_t ebreak_pc = 0x80000000;

VerilatedContext* contextp = NULL; // 上下文变量
VerilatedVcdC* tfp = NULL;         // 波形变量
																	 //
static void single_cycle() {
  dut->clk = ~dut->clk & 1; dut->eval();
}

void sim_init(int argc, char** argv ){
#ifdef MONITOR_EN
	init_sdb();
#endif
	contextp = new VerilatedContext;  
	contextp->commandArgs(argc, argv);
	dut = new Vysyx_25010009_top;                 
	dut->clk = 0;
	dut->rst = 1;

	if(argc < 2) assert(0);
	char *img_file = argv[1];
	FILE *img = fopen(img_file, "rb");
	load_img(img);
	pmem_load_img(img);
	fclose(img);

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

void reset_npc (){
	int i = 0;
	while(dut->rst){
		contextp->timeInc(1);
		single_cycle();
		if(i < RESET_TIME) i++;
		if(i == RESET_TIME) dut->rst = 0;
	}
}

void log_trap(){
	if(is_good_trap) {
		printf(ANSI_FMT("[%s:%d %s] npc: ", ANSI_FG_BLUE) ANSI_FMT("HIT GOOD TRAP", ANSI_FG_GREEN) " at pc = 0x%08x\n", STRIP_TO_CSRC(__FILE__), __LINE__, __func__, ebreak_pc);
	} else {
		printf(ANSI_FMT("[%s:%d %s] npc: ", ANSI_FG_BLUE) ANSI_FMT("HIT BAD TRAP", ANSI_FG_RED) " at pc = 0x%08x\n", STRIP_TO_CSRC(__FILE__), __LINE__, __func__, ebreak_pc);
	}
}

void exec_once(uint32_t n){
	uint32_t i = 0;
	if(end_sim) {
		printf("Program execution has ended. To restart the program, exit NEMU and run again.\n");
		return;
	}
	while(1){
		contextp->timeInc(1);
		single_cycle();
		printf("end_sim = %u\n", end_sim);
		if(end_sim) {
			log_trap();
			break;
		}
		if(stop_sim) {
			i++;
			if(i == n) break;
		}
	}
}


void main_loop(){
	reset_npc();
#ifdef MONITOR_EN
	sdb_mainloop();
#else
	while(1){
		contextp->timeInc(1);
		single_cycle();
		if(end_sim) {
			log_trap();
			break;
		}
	#ifdef ENABLE_WAVEFORM
		tfp->dump(contextp->time());
	#endif
	#ifdef ENABLE_NVBOARD
		nvboard_update();
	#endif
	}
#endif
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
	if(!is_good_trap) return 1;
	return 0;
}
