#include <Vysyx_25010009_top__Dpi.h>
//#include "irom.h"
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
#include <macro.h>
#include <ftrace.h>
#include <isa.h>
//#define CONFIG_WAVEFORM
#define RESET_TIME 10

#define STRIP_TO_CSRC(file) (strstr(file, "csrc/") ? strstr(file, "csrc/") : file)
#define IRING_PRINT() \
	do { \
		int cur = (ptr - 1 + IRINGBUF_DEPTH) % IRINGBUF_DEPTH; \
    for (int i = 0; i < IRINGBUF_DEPTH; i++) { \
      if (strlen(iringbuf[i]) == 0) continue; \
      if (i == cur) \
        printf(ANSI_FMT("%s", ANSI_FG_RED) "\n", iringbuf[i]); \
      else \
        printf("%s\n", iringbuf[i]); \
    } \
	} while(0)

int execed_once(int speec);

CPU_state cpu = {};
ISADecodeInfo decode = {};
extern "C" void disassemble(char *str, int size, uint64_t pc, uint8_t *code, int nbyte);
extern "C" void init_disasm(const char *triple);
bool access_device = false;
static int sim_time = 5000;
static TOP_NAME* dut;
void nvboard_bind_all_pins(TOP_NAME* top);
int end_sim = 0;
int once_sim = 0;
int stop_sim = 0;
bool is_good_trap = false;
uint32_t is_jal  = 0;
uint32_t is_jalr = 0;

VerilatedContext* contextp = NULL; // 上下文变量
VerilatedVcdC* tfp = NULL;         // 波形变量
																	 
void init_isa();
void init_mem();

void init_rand();
void init_difftest(char *ref_so_file, long img_size, int port);
void difftest_step(vaddr_t pc, vaddr_t npc);
void difftest_skip_ref();

static void single_cycle() {
	contextp->timeInc(1);
  dut->clk = ~dut->clk & 1; dut->eval();
	#ifdef CONFIG_WAVEFORM
		tfp->dump(contextp->time());
	#endif
}

void sim_init(int argc, char** argv ){
	init_rand();
	init_mem();
#ifdef CONFIG_MONITOR_EN
	init_sdb();
#endif
#ifdef CONFIG_ITRACE
	init_disasm("riscv32");
#endif
	contextp = new VerilatedContext;  
	contextp->commandArgs(argc, argv);
	dut = new Vysyx_25010009_top;                 
	dut->clk = 0;
	dut->rst = 1;

	if(argc < 3) assert(0);
	char *ref_so_file = argv[3];
	char *img_file = argv[1];
	elf_file = argv[2];
	printf("argv[0] = %s, argv[1] = %s, argv[2] = %s, argv[3] = %s\n", argv[0], argv[1], argv[2], argv[3]);
	FILE *img = fopen(img_file, "rb");
	long img_size = load_img(img);
#ifdef CONFIG_FTRACE
	init_ftmem();
#endif
	fclose(img);
	init_isa();

#ifdef CONFIG_DIFFTEST
	init_difftest(ref_so_file, img_size, 0);
#endif
	#ifdef CONFIG_WAVEFORM
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
		single_cycle();
		if(i < RESET_TIME) i++;
		if(i == RESET_TIME) dut->rst = 0;
	}
}

void log_trap(){
	if(is_good_trap) {
		printf(ANSI_FMT("[%s:%d %s] npc: ", ANSI_FG_BLUE) ANSI_FMT("HIT GOOD TRAP", ANSI_FG_GREEN) " at pc = 0x%08x\n", STRIP_TO_CSRC(__FILE__), __LINE__, __func__, cpu.pc);
	} else {
		printf(ANSI_FMT("[%s:%d %s] npc: ", ANSI_FG_BLUE) ANSI_FMT("HIT BAD TRAP", ANSI_FG_RED) " at pc = 0x%08x\n", STRIP_TO_CSRC(__FILE__), __LINE__, __func__, cpu.pc);
	}
	printf(ANSI_FMT("[%s:%d %s] clock cycles = %u\n", ANSI_FG_BLUE), STRIP_TO_CSRC(__FILE__), __LINE__, __func__, dut->counter);
}

#ifdef CONFIG_IRINGBUF
#define IRINGBUF_DEPTH 16
char iringbuf[IRINGBUF_DEPTH][128] = {};
int ptr = 0;
#endif

void trace_and_difftest(){
#ifdef CONFIG_DIFFTEST
	printf("access_device = %s\n", access_device ? "true" : "false");
	if(access_device) {
		difftest_skip_ref();
	}
	difftest_step(cpu.pc, cpu.dnpc);
#endif
#ifdef CONFIG_FTRACE
	if(decode.is_jal ) ftrace_jal (cpu.pc, cpu.dnpc, decode.rd);
	if(decode.is_jalr) ftrace_jalr(cpu.pc, cpu.dnpc, decode.rd, decode.rs1);
#endif
#ifdef CONFIG_IRINGBUF
  char *p = iringbuf[ptr];
  p += snprintf(p, sizeof(iringbuf[ptr]), FMT_WORD ":", cpu.pc);//pc
  int ilen = cpu.snpc - cpu.pc;
  uint8_t *inst = (uint8_t *)(&decode.inst);
  for (int k = ilen - 1; k >= 0; k --) {
    p += snprintf(p, 4, " %02x", inst[k]);//inst
  }
  int ilen_max = MUXDEF(CONFIG_ISA_x86, 8, 4);
  int space_len = ilen_max - ilen;
  if (space_len < 0) space_len = 0;
  space_len = space_len * 3 + 1;
  memset(p, ' ', space_len);
  p += space_len;
  disassemble(p, iringbuf[ptr] + sizeof(iringbuf[ptr]) - p, cpu.pc, (uint8_t *)(&decode.inst), ilen);
	ptr = (ptr+1) % IRINGBUF_DEPTH;
#endif
#ifdef CONFIG_WATCHPOINT
  WP* p = head;
  WP* temp[32] = {};
	int ind = 0;
	uint32_t res[32] = {};
	while(p){
		bool suc = true;
		expr(p->expr, &suc, &res[ind]);
		if(!suc) {
			return;
		}
		if(res[ind] != p->result){
			stop_sim = 1;
			temp[ind++] = p;
		}
		p = p->next;
	}
	for(int i = 0; i < ind; i++){
		printf("\nwatch point %d : %s\n", temp[i]->NO, temp[i]->expr);
		printf("\nOld value : 0x%x\n", temp[i]->result);
		printf("New value : 0x%x\n", res[i]);//怎么定位行号?
		temp[i]->result = res[i];
	}
#endif
	return;
}

void exec_once(uint32_t n){
	uint32_t i = 0;
#ifdef CONFIG_MONITOR_EN
	if(end_sim) {
		printf("Program execution has ended. To restart the program, exit sdb and run again.\n");
		return;
	}
#endif
	while(1){
		access_device = false;
		once_sim = 0;
	#ifdef CONFIG_MONITOR_EN
		stop_sim = 0;
	#endif
		single_cycle();
		if(once_sim) {
			trace_and_difftest();
	#ifdef CONFIG_MONITOR_EN
			if(stop_sim) break;
	#endif
			i++;
			if(i == n) break;
		}
		if(end_sim) {
			break;
		}
	#ifdef ENABLE_NVBOARD
		nvboard_update();
	#endif
	}
}

void main_loop(){
	reset_npc();
#ifdef CONFIG_MONITOR_EN
	sdb_mainloop();
#else
	exec_once(-1);
//	while(1){
//		access_device = false;
//		once_sim = 0;
//		single_cycle();
//		if(once_sim) {
//			trace_and_difftest();
//		}
//		if(end_sim) {
//			break;
//		}
//	}
#endif
}

void sim_exit(){
#ifdef CONFIG_WAVEFORM
	if(tfp){
		tfp->close();
		delete tfp;
	}
#endif
#ifdef ENABLE_NVBOARD
	nvboard_quit();
#endif
	free_ft();
	delete dut;
	delete contextp;
}

int main(int argc, char** argv) {
	sim_init(argc, argv);
	main_loop();
#ifdef CONFIG_IRINGBUF
	IRING_PRINT();
#endif
#ifdef CONFIG_FTRACE
	output_ftmem();
#endif
  log_trap();
	sim_exit();
	if(!is_good_trap) return 1;
	return 0;
}
