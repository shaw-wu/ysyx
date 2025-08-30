#include "Vysyx_25010009_top__Dpi.h"
#include "irom.h"
#include <cassert>

static uint32_t ROM[ROM_SIZE];

void load_rom(FILE *fp){
	char line[10] = {};
	int i;
	printf("load coe\n");
	while(fgets(line, sizeof(line), fp)){
		uint32_t inst;
		sscanf(line, "%08x", &inst);
		ROM[i++] = inst;
	  printf("inst:%08x, ROM[%d]:%08x\n", inst, i-1, ROM[i-1]);
	}
	return;
}

extern uint32_t read_irom(uint32_t vaddr){
	printf("2\n");
	uint32_t paddr = vaddr >> 2;	
	return ROM[paddr];
}
