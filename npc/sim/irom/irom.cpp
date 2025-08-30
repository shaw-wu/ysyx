#include <svdpi.h>
#include <Vysyx_25010009_top__Dpi.h>
#include "irom.h"
#include <cassert>

static int ROM[ROM_SIZE];

void load_rom(FILE *fp){
	char line[10] = {};
	int i;
	printf("load coe\n");
	while(fgets(line, sizeof(line), fp)){
		int inst;
		sscanf(line, "%08x", &inst);
		ROM[i++] = inst;
	  printf("inst:%08x, ROM[%d]:%08x\n", inst, i-1, ROM[i-1]);
	}
	return;
}

int read_irom(int vaddr){
	for(int i = 0; i < 4; i ++) printf("ROM[%d]:%08x\n", i, ROM[i]);
	int paddr = vaddr & 0x00000ffe >> 2;	
	return ROM[paddr];
}
