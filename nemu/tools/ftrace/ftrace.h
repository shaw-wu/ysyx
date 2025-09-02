#ifndef __FTRACE_H__
#define __FTRACE_H__

#include <isa.h>

extern FILE* elf_file;
extern bool have_img;
extern bool is_call;
extern bool is_ret;
extern vaddr_t dnpc;

#endif
