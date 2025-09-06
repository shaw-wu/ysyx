#include <svdpi.h>
#include <Vysyx_25010009_top__Dpi.h>

extern int stop_sim;

void speec_once (int speec){
	stop_sim = speec;
}
