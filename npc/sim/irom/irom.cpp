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
		sscanf(line, "%8x", &inst);
		ROM[i++] = inst;
	  printf("%u\n", ROM[i]);
	}
	return;
}

uint32_t read_irom(uint32_t vaddr){
	printf("2\n");
	uint32_t paddr = vaddr >> 2;	
	return ROM[paddr];
}
