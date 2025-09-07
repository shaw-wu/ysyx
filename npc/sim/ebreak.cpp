#include <svdpi.h>
#include <Vysyx_25010009_top__Dpi.h>
#include <isa.h>
#include <stdio.h>

void is_ebreak(uint32_t ebreak, uint32_t a0, uint32_t pc, uint32_t snpc, uint32_t dnpc, uint32_t inst, uint32_t rd, uint32_t rs1, uint32_t jal, uint32_t jalr){
	cpu.pc   = pc  ;
	cpu.snpc = snpc;
	cpu.dnpc = dnpc;
	decode.inst = inst;
	decode.rd   = rd  ;
	decode.rs1  = rs1 ;
	decode.is_jal  = jal ;
	decode.is_jalr = jalr;
  if(ebreak) {
		end_sim = 1;
		if(a0 == 0) is_good_trap = true;
	}
	return;
}
