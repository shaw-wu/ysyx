#include <nvboard.h>
#include "verilated.h"
#include "verilated_vcd_c.h"
#include <Vtop.h>

// 改为指针
static TOP_NAME* dut;
VerilatedContext* contextp = NULL;
VerilatedVcdC* tfp = NULL;

void nvboard_bind_all_pins(TOP_NAME* top);

static void single_cycle() {
  dut->clk = 0; dut->eval();
  if (tfp) tfp->dump(contextp->time());
  contextp->timeInc(1); // 在时钟半周期推进时间

  dut->clk = 1; dut->eval();
  if (tfp) tfp->dump(contextp->time());
  contextp->timeInc(1); // 在另一个半周期推进时间
}

static void reset(int n) {
  dut->rstn = 0;
  while (n -- > 0) single_cycle();
  dut->rstn = 1;
}

int main(int argc, char** argv) {
  contextp = new VerilatedContext;
  contextp->commandArgs(argc, argv);

#ifdef ENABLE_WAVEFORM
  // 必须在实例化 dut 之前调用
  Verilated::traceEverOn(true);
#endif

  dut = new TOP_NAME; // 在这里实例化

#ifdef ENABLE_WAVEFORM
  tfp = new VerilatedVcdC;
  dut->trace(tfp, 99);
  tfp->open("build/dump.vcd");
#endif

  nvboard_init();
  nvboard_bind_all_pins(dut);

  reset(10);

  while (!contextp->gotFinish()) {
    nvboard_update();
    single_cycle();
  }

  nvboard_quit();
  if (tfp) { tfp->close(); delete tfp; }
  delete dut;
  delete contextp;
  return 0;
}
//#include <nvboard.h>
//#include "verilated.h"
//#include "verilated_vcd_c.h"
//#include <Vtop.h>
//
//static TOP_NAME dut;
//
//VerilatedContext* contextp = NULL; // 上下文变量
//VerilatedVcdC* tfp = NULL;         // 波形变量
//void nvboard_bind_all_pins(TOP_NAME* top);
//
//static void single_cycle() {
//  dut.clk = 0; dut.eval();
//  dut.clk = 1; dut.eval();
//}
//
//static void reset(int n) {
//  dut.rstn = 0;
//  while (n -- > 0) single_cycle();
//  dut.rstn = 1;
//}
//
//int main() {
//  contextp = new VerilatedContext;  
//#ifdef ENABLE_WAVEFORM
//  Verilated::traceEverOn(true);
//  tfp = new VerilatedVcdC;
//  dut.trace(tfp, 99);
//  tfp->open("build/dump.vcd");
//#endif
//  nvboard_bind_all_pins(&dut);
//  nvboard_init();
//
//  reset(10);
//
//  while(1) {
//    contextp->timeInc(1);
//    nvboard_update();
//    single_cycle();
//	#ifdef ENABLE_WAVEFORM
//		tfp->dump(contextp->time());
//	#endif
//  }
//}
