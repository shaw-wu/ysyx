#include <svdpi.h>
#include <Vysyx_25010009_top__Dpi.h>
#include <ebreak.h>

void is_ebreak(int ebreak, int a0, int pc){
  if(ebreak) {
		stop_sim = 1;
		ebreak_pc = (uint32_t)pc;
		if((uint32_t)a0 == 0) is_good_trap = true;
	}
	return;
}
