#include <isa.h>

void init_isa(){
	cpu.pc = RESET_VECTOR;
	cpu.gpr[0] = 0;
}

