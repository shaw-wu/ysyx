#include <ftrace.h>

FILE* elf_file = NULL;
bool have_img = false;
bool is_call = false;
bool is_ret = false;
vaddr_t dnpc = 0;
