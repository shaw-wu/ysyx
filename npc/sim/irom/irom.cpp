#include "Vysyx_25010009_top__Dpi.h"
#include "irom.h"

static uint32_t ROM[ROM_SIZE];

void load_rom(FILE *fp){
	char line[8] = {};
	int i;
	while(fgets(line, sizeof(line), fp)){
		uint32_t inst;
		sscanf(line, "%8x", &inst);
		ROM[i++] = inst;
	}
	return;
}

uint32_t read_irom(uint32_t vaddr){
	uint32_t paddr = vaddr >> 2;	
	return ROM[paddr];
}
