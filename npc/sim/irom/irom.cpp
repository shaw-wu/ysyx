#include <svdpi.h>
#include <Vysyx_25010009_top__Dpi.h>
#include "irom.h"
#include <cassert>

static int ROM[ROM_SIZE] = {};

long load_img(FILE *fp){
	fseek(fp, 0, SEEK_END);
	long size = ftell(fp);
	fseek(fp, 0, SEEK_SET);

	size_t read_bytes = fread(ROM, 1, size, fp);
	if (read_bytes != size) {
    fprintf(stderr, "Read error: expected %ld bytes, got %zu\n", size, read_bytes);
  }
	return size;
}

int read_irom(int vaddr){
	int paddr = (vaddr & 0x00000ffe) >> 2;	
	return ROM[paddr];
}
