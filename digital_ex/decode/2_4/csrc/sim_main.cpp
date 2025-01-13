#include "Vdecode.h"
#include "verilated.h"
#include <verilated_vcd_c.h>
#include <nvboard.h>

VerilatedContext* contextp = NULL; // 声明上下文变量
VerilatedVcdC* tfp = NULL;         // 声明波形变量

static Vdecode* top;               // 声明模块变量
static TOP_NAME dut;
void nvboard_bind_all_pins(TOP_NAME* top);

void step_and_dump_wave(){
	top->eval();                     // 更新电路状态
	contextp->timeInc(1);            // 时间宽度设为1
	tfp->dump(contextp->time());     // 波形时间宽度设置
}
void sim_init(int argc, char** argv ){
//	contextp = new VerilatedContext;  // 初始化
	//tfp = new VerilatedVcdC;
//	contextp->commandArgs(argc, argv);
//	top = new Vdecode;                 // 实例化模块
	nvboard_bind_all_pins(&dut);
	nvboard_init();
	//contextp->traceEverOn(true);      // 打开波形跟踪
	//top->trace(tfp, 0);               // 链接跟踪变量tfp与实例化模块top
	//tfp->open("dump.vcd");            // 创建文件
}
void sim_exit(){
//	step_and_dump_wave();   //
//	tfp->close();           // 关闭tfp
}

int main(int argc, char** argv) {
	sim_init(argc, argv);
/*
	top->s=0; top->a=0; top->b=0;  step_and_dump_wave();   // 将s，a和b均初始化为“0”
                      top->b=1;  step_and_dump_wave();   // 将b改为“1”，s和a的值不变，继续保持“0”，
            top->a=1; top->b=0;  step_and_dump_wave();   // 将a，b分别改为“1”和“0”，s的值不变，
                      top->b=1;  step_and_dump_wave();   // 将b改为“1”，s和a的值不变，维持10个时间单位
  top->s=1; top->a=0; top->b=0;  step_and_dump_wave();   // 将s，a，b分别变为“1,0,0”，维持10个时间单位
                      top->b=1;  step_and_dump_wave();
            top->a=1; top->b=0;  step_and_dump_wave();
                      top->b=1;  step_and_dump_wave();
*/	
	while(1){
		dut.eval();
		nvboard_update();
	}
	nvboard_quit();
	delete top;
	delete contextp;
	return 0;
}
