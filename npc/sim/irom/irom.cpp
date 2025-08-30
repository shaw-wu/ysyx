#include "Vysyx_25010009_top__Dpi.h"
#include "irom.h"
#include <cassert>

static uint32_t ROM[ROM_SIZE];

void load_rom(FILE *fp){
	char line[8] = {};
	int i;
	printf("0\n");
	assert(fp);
	while(fgets(line, sizeof(line), fp)){
		uint32_t inst;
	  printf("0%u\n", ROM[i]);
		sscanf(line, "%8x", &inst);
	  printf("1%u\n", ROM[i]);
		ROM[i++] = inst;
	}
	return;
}

uint32_t read_irom(uint32_t vaddr){
	printf("2\n");
	uint32_t paddr = vaddr >> 2;	
	return ROM[paddr];
}
