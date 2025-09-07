#include <svdpi.h>
#include <Vysyx_25010009_top__Dpi.h>
#include <ebreak.h>
#include <stdio.h>

void is_ebreak(uint32_t ebreak, uint32_t a0, uint32_t pc, uint32_t snpc, uint32_t dnpc, uint32_t inst, uint32_t rd, uint32_t rs1, uint32_t jal, uint32_t jalr){
	ebreak_pc   = pc  ;
	ebreak_snpc = snpc;
	ebreak_dnpc = dnpc;
	ebreak_inst = inst;
	ebreak_rd   = rd  ;
	ebreak_rs1  = rs1 ;
	is_jal  = jal ;
	is_jalr = jalr;
  if(ebreak) {
		end_sim = 1;
		if(a0 == 0) is_good_trap = true;
	}
	return;
}
