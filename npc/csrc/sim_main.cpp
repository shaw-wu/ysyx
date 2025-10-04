//#include <Vysyx_25010009_top__Dpi.h>
//#include "irom.h"
//#include <paddr.h>
#include "VysyxSoCFull.h"
#include "verilated.h"
#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <assert.h>
#include "verilated_vcd_c.h"
#include <debug.h>
//#include <nvboard.h>
//#include <ebreak.h>
//#include <sdb.h>
//#include <utils.h>
//#include <macro.h>
//#include <ftrace.h>
//#include <isa.h>
//#define ENABLE_WAVEFORM
#define RESET_TIME 1000
//#define FLASH_SIZE 1024*1024*16
#define FLASH_DEPTH 1024*1024*4 

//#define STRIP_TO_CSRC(file) (strstr(file, "csrc/") ? strstr(file, "csrc/") : file)
//#define IRING_PRINT() \
//	do { \
//		int cur = (ptr - 1 + IRINGBUF_DEPTH) % IRINGBUF_DEPTH; \
//    for (int i = 0; i < IRINGBUF_DEPTH; i++) { \
//      if (strlen(iringbuf[i]) == 0) continue; \
//      if (i == cur) \
//        printf(ANSI_FMT("%s", ANSI_FG_RED) "\n", iringbuf[i]); \
//      else \
//        printf("%s\n", iringbuf[i]); \
//    } \
//	} while(0)

//int execed_once(int speec);

//CPU_state cpu = {};

//ISADecodeInfo decode = {};
//extern "C" void disassemble(char *str, int size, uint64_t pc, uint8_t *code, int nbyte);
//extern "C" void init_disasm(const char *triple);
static int sim_time = 5000;
static TOP_NAME* dut;
//void nvboard_bind_all_pins(TOP_NAME* top);
int end_sim = 0;
//int once_sim = 0;
//int stop_sim = 0;
bool is_good_trap = false;
//uint32_t is_jal  = 0;
//uint32_t is_jalr = 0;
static uint8_t flash_mem [FLASH_DEPTH];
VerilatedContext* contextp = NULL; // 上下文变量
VerilatedVcdC* tfp = NULL;         // 波形变量
																	 
//void init_isa();

//void init_rand();
//void init_difftest(char *ref_so_file, long img_size, int port);
//void difftest_step(vaddr_t pc, vaddr_t npc);

extern "C" void flash_read(int32_t addr, int32_t *data) {
	*data = (int32_t)(flash_mem[addr+3] << 24 | flash_mem[addr+2] << 16 | flash_mem[addr+1] << 8 | flash_mem[addr]);
	//printf("flash_mem[%x] = %x\n", addr, *data);
}

static void single_cycle() {
  dut->clock = ~dut->clock & 1; dut->eval();
}

void sim_init(int argc, char** argv ){
	//init_rand();
//#ifdef MONITOR_EN
//	init_sdb();
//#endif
//#ifdef CONFIG_ITRACE
//	init_disasm("riscv32");
//#endif
	contextp = new VerilatedContext;  
	contextp->commandArgs(argc, argv);
	dut = new VysyxSoCFull;                 
	dut->clock = 0;
	dut->reset = 1;

	char *img_file = "./bin/new-hello-minirv-npc.bin"; 
	//char *img_file = "./bin/hello-minirv-ysyxsoc.bin"; 
	FILE *img = fopen(img_file, "rb");
	assert(img);
	fseek(img, 0, SEEK_END);
	long imgsize = ftell(img);
	rewind(img);
	size_t read_count = fread(flash_mem, 1, imgsize, img);
  if (read_count != imgsize) {
    printf("Error reading file.\n");
    fclose(img);
  }
	fclose(img);
	
//	if(argc < 3) assert(0);
//	char *ref_so_file = argv[3];
//	char *img_file = argv[1];
//	elf_file = argv[2];
//	printf("argv[0] = %s, argv[1] = %s, argv[2] = %s, argv[3] = %s\n", argv[0], argv[1], argv[2], argv[3]);
//	FILE *img = fopen(img_file, "rb");
//	long img_size = load_img(img);
//	init_ftmem();
//	fclose(img);
//	init_isa();

//#ifdef CONFIG_DIFFTEST
//	init_difftest(ref_so_file, img_size, 0);
//#endif
	#ifdef ENABLE_WAVEFORM
		Verilated::traceEverOn(true);
		tfp = new VerilatedVcdC;
		dut->trace(tfp, 99);
		tfp->open("build/dump.vcd");
	#endif
//	#ifdef ENABLE_NVBOARD
//	nvboard_bind_all_pins(dut);
//	nvboard_init();
//	#endif
}

void reset_npc (){
	int i = 0;
	while(dut->reset){
		contextp->timeInc(1);
		single_cycle();
		if(i < RESET_TIME) i++;
		if(i == RESET_TIME) dut->reset = 0;
	#ifdef ENABLE_WAVEFORM
		tfp->dump(contextp->time());
	#endif
	}
}

void log_trap(){
	if(is_good_trap) {
		printf(ANSI_FMT("HIT GOOD TRAP\n", ANSI_FG_GREEN));
	} else {
		printf(ANSI_FMT("HIT BAD TRAP\n", ANSI_FG_RED));
	}
	//if(is_good_trap) {
	//	printf(ANSI_FMT("[%s:%d %s] npc: ", ANSI_FG_BLUE) ANSI_FMT("HIT GOOD TRAP", ANSI_FG_GREEN) " at pc = 0x%08x\n", STRIP_TO_CSRC(__FILE__), __LINE__, __func__, cpu.pc);
	//} else {
	//	printf(ANSI_FMT("[%s:%d %s] npc: ", ANSI_FG_BLUE) ANSI_FMT("HIT BAD TRAP", ANSI_FG_RED) " at pc = 0x%08x\n", STRIP_TO_CSRC(__FILE__), __LINE__, __func__, cpu.pc);
	//}
}

//#ifdef CONFIG_IRINGBUF
//#define IRINGBUF_DEPTH 16
//char iringbuf[IRINGBUF_DEPTH][128] = {};
//int ptr = 0;
//#endif
//
//void trace_and_difftest(){
//#ifdef CONFIG_DIFFTEST
//	difftest_step(cpu.pc, cpu.dnpc);
//#endif
//#ifdef CONFIG_FTRACE
//	if(decode.is_jal ) ftrace_jal (cpu.pc, cpu.dnpc, decode.rd);
//	if(decode.is_jalr) ftrace_jalr(cpu.pc, cpu.dnpc, decode.rd, decode.rs1);
//#endif
//#ifdef CONFIG_IRINGBUF
//  char *p = iringbuf[ptr];
//  p += snprintf(p, sizeof(iringbuf[ptr]), FMT_WORD ":", cpu.pc);//pc
//  int ilen = cpu.snpc - cpu.pc;
//  uint8_t *inst = (uint8_t *)(&decode.inst);
//  for (int k = ilen - 1; k >= 0; k --) {
//    p += snprintf(p, 4, " %02x", inst[k]);//inst
//  }
//  int ilen_max = MUXDEF(CONFIG_ISA_x86, 8, 4);
//  int space_len = ilen_max - ilen;
//  if (space_len < 0) space_len = 0;
//  space_len = space_len * 3 + 1;
//  memset(p, ' ', space_len);
//  p += space_len;
//  disassemble(p, iringbuf[ptr] + sizeof(iringbuf[ptr]) - p, cpu.pc, (uint8_t *)(&decode.inst), ilen);
//	ptr = (ptr+1) % IRINGBUF_DEPTH;
//#endif
//#ifdef CONFIG_WATCHPOINT
//  WP* p = head;
//  WP* temp[32] = {};
//	int ind = 0;
//	uint32_t res[32] = {};
//	while(p){
//		bool suc = true;
//		expr(p->expr, &suc, &res[ind]);
//		if(!suc) {
//			return;
//		}
//		if(res[ind] != p->result){
//			stop_sim = 1;
//			temp[ind++] = p;
//		}
//		p = p->next;
//	}
//	for(int i = 0; i < ind; i++){
//		printf("\nwatch point %d : %s\n", temp[i]->NO, temp[i]->expr);
//		printf("\nOld value : 0x%x\n", temp[i]->result);
//		printf("New value : 0x%x\n", res[i]);//怎么定位行号?
//		temp[i]->result = res[i];
//	}
//#endif
//	return;
//}

//void exec_once(uint32_t n){
//	uint32_t i = 0;
//	if(end_sim) {
//		printf("Program execution has ended. To restart the program, exit sdb and run again.\n");
//		return;
//	}
//	while(1){
//		once_sim = 0;
//		stop_sim = 0;
//		contextp->timeInc(1);
//		single_cycle();
//		if(end_sim) {
//			break;
//		}
//		if(once_sim) {
//			trace_and_difftest();
//			i++;
//			if(stop_sim) break;
//			if(i == n) break;
//		}
//	}
//}

void main_loop(){
	reset_npc();
//#ifdef MONITOR_EN
//	sdb_mainloop();
//#else
	while(1){
		//once_sim = 0;
		contextp->timeInc(1);
		single_cycle();
		//if(once_sim) {
		//	trace_and_difftest();
		//}
		if(end_sim) {
			break;
		}
	#ifdef ENABLE_WAVEFORM
		tfp->dump(contextp->time());
	#endif
//	#ifdef ENABLE_NVBOARD
//		nvboard_update();
//	#endif
	}
//#endif
}

void sim_exit(){
#ifdef ENABLE_WAVEFORM
	if(tfp){
		tfp->close();
		delete tfp;
	}
#endif
//#ifdef ENABLE_NVBOARD
//	nvboard_quit();
//#endif
	//free_ft();
	delete dut;
	delete contextp;
}

int main(int argc, char** argv) {
	sim_init(argc, argv);
	main_loop();
//#ifdef CONFIG_IRINGBUF
//	IRING_PRINT();
//#endif
//#ifdef CONFIG_FTRACE
//	output_ftmem();
//#endif
  log_trap();
	sim_exit();
	if(!is_good_trap) return 1;
	return 0;
}
