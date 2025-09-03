#ifndef __FTRACE_H__
#define __FTRACE_H__

#include <stdint.h>
#include <stdbool.h>
#include <isa.h>

extern char* elf_file;
extern bool have_img;
extern bool is_call;
extern bool is_ret;
extern vaddr_t dnpc;

extern Elf32_Sym* symtab = NULL; 
extern char **sym_name = NULL;
extern int sym_count = 0; 

#endif
