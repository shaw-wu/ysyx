#include <svdpi.h>
#include <Vysyx_25010009_top__Dpi.h>
#include <ebreak.h>

void is_ebreak(uint32_t ebreak, uint32_t a0, uint32_t pc, uint32_t snpc, uint32_t inst){
	ebreak_pc   = pc  ;
	ebreak_snpc = snpc;
	ebreak_inst  = inst;
  if(ebreak) {
		end_sim = 1;
		if(a0 == 0) is_good_trap = true;
	}
	return;
}
