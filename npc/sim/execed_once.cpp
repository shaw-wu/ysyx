#include <svdpi.h>
#include <stdio.h>
#include <Vysyx_25010009_soc_top__Dpi.h>

extern int once_sim;

void speec_once (int speec){
	once_sim = speec;
}
