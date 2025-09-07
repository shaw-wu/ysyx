#ifndef __FTRACE_H__
#define __FTRACE_H__

#include <stdint.h>
#include <stdbool.h>

extern char* elf_file;
extern bool have_img;

void init_ftmem();
void update_ftmem(uint32_t addr, uint32_t target, bool is_ret, bool is_call);
void output_ftmem();
void free_ft();

void ftrace_jal (vaddr_t pc, vaddr_t dnpc, uint32_t rd);
void ftrace_jalr(vaddr_t pc, vaddr_t dnpc, uint32_t rd, uint32_t rs1);

#endif
