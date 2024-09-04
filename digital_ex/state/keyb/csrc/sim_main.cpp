#include "Vhandle.h"
#include "verilated.h"
#include <verilated_vcd_c.h>
#include <nvboard.h>

VerilatedContext* contextp = NULL; // 声明上下文变量
VerilatedVcdC* tfp = NULL;         // 声明波形变量

static Vhandle* top;               // 声明模块变量
static TOP_NAME dut;
void nvboard_bind_all_pins(TOP_NAME* top);

void step_and_dump_wave(){
	top->eval();                     // 更新电路状态
	contextp->timeInc(1);            // 时间宽度设为1
	tfp->dump(contextp->time());     // 波形时间宽度设置
}
void sim_init(int argc, char** argv ){
	contextp = new VerilatedContext;  // 初始化
	tfp = new VerilatedVcdC;
	contextp->commandArgs(argc, argv);
	top = new Vhandle;                 // 实例化模块
	nvboard_bind_all_pins(&dut);
	nvboard_init();
	contextp->traceEverOn(true);      // 打开波形跟踪
	top->trace(tfp, 0);               // 链接跟踪变量tfp与实例化模块top
	tfp->open("dump.vcd");            // 创建文件
}
void sim_exit(){
	step_and_dump_wave();   //
	tfp->close();           // 关闭tfp
}

int main(int argc, char** argv) {
	sim_init(argc, argv);
	while(1){
		dut.eval();
		nvboard_update();
	}
	nvboard_quit();
	delete top;
	delete contextp;
	return 0;
}
