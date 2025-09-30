#include <isa.h>

void init_isa(){
	memset(cpu.csrs_valid, 0, sizeof(cpu.csrs_valid));
  cpu.csrs_valid[MSTATUS  ] = 1;
  cpu.csrs_valid[MTVEC	  ] = 1;
  cpu.csrs_valid[MEPC		  ] = 1;
  cpu.csrs_valid[MCAUSE   ] = 1;
  cpu.csrs_valid[MCYCLE   ] = 1;
  cpu.csrs_valid[MVENDORID] = 1;
  cpu.csrs_valid[MARCHID	] = 1;
	cpu.pc = RESET_VECTOR;
	cpu.gpr[0] = 0;
  cpu.csrs[MVENDORID] = 0x79737978;
  cpu.csrs[MARCHID] = 0x17d9f59;
}

