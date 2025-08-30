#include <svdpi.h>
#include <Vysyx_25010009_top__Dpi.h>
#include <ebreak.h>
#include <cassert>

void is_ebreak(int ebreak){
	assert(0);
  if(ebreak) stop_sim = 1; 
	return;
}
