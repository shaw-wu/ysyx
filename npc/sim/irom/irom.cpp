#include "Vour__Dpi.h"
#include "irom.h"

static uint32_t ROM[ROM_MSIZE];

void load_rom(FILE *fp){
	uint32_t line[ROM_MSIZE] = {};
	int i;
	while(fgets(line, sizeof(line), fp)){
		uint32_t inst;
		sscanf(line, "%8x", &inst);
		ROM[i++] = line;
	}
}

uint32_t read_irom(uint32_t vaddr){
	uint32_t paddr = vaddr >> 2;	
	return ROM[paddr];
}
