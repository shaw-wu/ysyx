#ifndef __FTRACE_H__
#define __FTRACE_H__

#include <stdint.h>
#include <stdbool.h>
#include <isa.h>
//#define IRINGBUF_DEPTH 16

extern char* elf_file;
extern bool have_img;

void init_ftmem();
void update_ftmem(uint32_t addr, uint32_t target, bool is_ret, bool is_call);
void output_ftmem();
void free_ft();

#endif
