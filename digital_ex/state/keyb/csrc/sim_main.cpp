#include "Vtop.h"
#include "verilated.h"
#include <verilated_vcd_c.h>
#include <nvboard.h>

#define CONFIG_NVBOARD
//#define CONFIG_WAVE

VerilatedContext* contextp = NULL; // 声明上下文变量
static Vtop* top;               // 声明模块变量
VerilatedVcdC* tfp = NULL;         // 声明波形变量

//波形时间
void step_and_dump_wave(){
	top->eval();                     // 更新电路状态
	contextp->timeInc(1);            // 时间宽度设为1
	tfp->dump(contextp->time());     // 波形时间宽度设置
}

static TOP_NAME dut;
void nvboard_bind_all_pins(TOP_NAME* top);

//  单周期时钟
static void single_cycle() {
	dut.clk = 0;dut.eval();
	dut.clk = 1;dut.eval();
}

// 复位
static void reset(int n) {
	dut.clrn = 0;
	while (n -- > 0) single_cycle();
	dut.clrn = 1;
}

void sim_init(int argc, char** argv ){
#ifdef CONFIG_NVBOARD
	nvboard_bind_all_pins(&dut);
	nvboard_init();
	reset(10);
#endif

#ifdef CONFIG_VERILATOR
	contextp = new VerilatedContext;  // 初始化
	tfp = new VerilatedVcdC;
	contextp->commandArgs(argc, argv);
	top = new Vtop;                 // 实例化模块
#endif

#ifdef CONFIG_WAVE
	contextp->traceEverOn(true);      // 打开波形跟踪
	top->trace(tfp, 0);               // 链接跟踪变量tfp与实例化模块top
	tfp->open("dump.vcd");            // 创建文件
#endif
}

// 退出仿真
void sim_exit(){
/*#ifdef CONFIG_WAVE
	step_and_dump_wave();   //
#endif*/
	tfp->close();           // 关闭tfp
}


int main(int argc, char** argv) {
	sim_init(argc, argv);
	while(1){
#ifdef CONFIG_NVBOARD
		nvboard_update();
		single_cycle();
#endif
	//  dut.eval();
#ifdef CONFIG_WAVE
		step_and_dump_wave();
#endif
	}
#ifdef CONFIG_NVBOARD
	nvboard_quit();
#endif
	delete top;
	delete contextp;
	return 0;
}
