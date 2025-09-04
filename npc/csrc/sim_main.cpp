#include <Vysyx_25010009_top__Dpi.h>
#include "irom.h"
#include "Vysyx_25010009_top.h"
#include "verilated.h"
#include <stdio.h>
#include <stdlib.h>
#include <assert.h>
#include "verilated_vcd_c.h"
#include <nvboard.h>
#include <ebreak.h>
#define ENABLE_WAVEFORM
#define RESET_TIME 10

#define STRIP_TO_CSRC(file) (strstr(file, "csrc/") ? strstr(file, "csrc/") : file)

#define ANSI_FG_BLACK   "\33[1;30m"
#define ANSI_FG_RED     "\33[1;31m"
#define ANSI_FG_GREEN   "\33[1;32m"
#define ANSI_FG_YELLOW  "\33[1;33m"
#define ANSI_FG_BLUE    "\33[1;34m"
#define ANSI_FG_MAGENTA "\33[1;35m"
#define ANSI_FG_CYAN    "\33[1;36m"
#define ANSI_FG_WHITE   "\33[1;37m"
#define ANSI_BG_BLACK   "\33[1;40m"
#define ANSI_BG_RED     "\33[1;41m"
#define ANSI_BG_GREEN   "\33[1;42m"
#define ANSI_BG_YELLOW  "\33[1;43m"
#define ANSI_BG_BLUE    "\33[1;44m"
#define ANSI_BG_MAGENTA "\33[1;35m"
#define ANSI_BG_CYAN    "\33[1;46m"
#define ANSI_BG_WHITE   "\33[1;47m"
#define ANSI_NONE       "\33[0m"

#define ANSI_FMT(str, fmt) fmt str ANSI_NONE

static int sim_time = 5000;
static TOP_NAME* dut;
void nvboard_bind_all_pins(TOP_NAME* top);
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
	contextp = new VerilatedContext;  
	contextp->commandArgs(argc, argv);
	dut = new Vysyx_25010009_top;                 
	dut->clk = 0;
	dut->rst = 1;

	if(argc < 2) assert(0);
	char *img_file = argv[1];
	FILE *coe = fopen(img_file, "rb");
	load_img(coe);
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
		if(stop_sim) {
			if(is_good_trap) {
				printf(ANSI_FMT("[%s:%d %s] npc: ", ANSI_FG_BLUE) ANSI_FMT("HIT GOOD TRAP", ANSI_FG_GREEN) " at pc = 0x%08x\n", STRIP_TO_CSRC(__FILE__), __LINE__, __func__, ebreak_pc);
			} else {
				printf(ANSI_FMT("[%s:%d %s] npc: ", ANSI_FG_BLUE) ANSI_FMT("HIT BAD TRAP", ANSI_FG_RED) " at pc = 0x%08x\n", STRIP_TO_CSRC(__FILE__), __LINE__, __func__, ebreak_pc);
			}
			break;
		}
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
	if(!is_good_trap) return 1;
	return 0;
}
