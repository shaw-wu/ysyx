#ifndef IROM_H
#define IROM_H

#define ROM_SIZE 1024
#define ADDR_WIDTH 10

void load_rom(FILE *fp);
uint32_t read_irom(uint32_t vaddr);

#endif
