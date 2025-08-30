
#ifndef IROM_H
#define IROM_H

#include <stdint.h>
#include <stdio.h>

#define ROM_SIZE 1024
#define ADDR_WIDTH 10

void load_rom(FILE *fp);
//extern uint32_t read_irom(uint32_t vaddr);

#endif
