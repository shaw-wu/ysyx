#include <svdpi.h>
#include <Vysyx_25010009_soc_top__Dpi.h>
#include <isa.h>
#include <stdio.h>

extern "C" void use_device(int is_device){
    access_device = is_device == 1 ? true : false;
	return;
}
