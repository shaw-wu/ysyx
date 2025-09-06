#include <Vysyx_25010009_top__Dpi.h>
#include <svdpi.h>
#include <string.h>
#include <common.h>

const char *regs[] = {
  "$0", "ra", "sp", "gp", "tp", "t0", "t1", "t2",
  "s0", "s1", "a0", "a1", "a2", "a3", "a4", "a5",
  "a6", "a7", "s2", "s3", "s4", "s5", "s6", "s7",
  "s8", "s9", "s10", "s11", "t3", "t4", "t5", "t6"
};

void isa_reg_display() {
	svScope scope = svGetScopeFromName("TOP.ysyx_25010009_top.GPR");
  if (!scope) {
      fprintf(stderr, "Error: Cannot find DPI scope!\n");
      exit(1);
  }
  svSetScope(scope);
	int i, j;
	i = 0;
	int reg = 0;
	for(j = 0; j < 8; j++){
		for(; i < (j + 1) * 4; i++){
			read_gpr(i, &reg);
			if(strcmp(regs[i], "s10") == 0 || strcmp(regs[i], "s11") == 0) {
				printf("%s : 0x%-15x", regs[i], reg);
			}
			else {
				printf("%s  : 0x%-15x", regs[i], reg);
			}
	}
		printf("\n");
	}
	return;
}

word_t isa_reg_str2val(const char *s, bool *success) {
//	int i = 0;
//	//读取pc
//	if(strcmp(s, "pc") == 0){
//		*success = true;
//		return read_pc();
//	}
//	//遍历32个寄存器
//	for(; i < 32; i++){
//		if(strcmp(s, regs[i]) == 0){
//			break;
//		}
//	}
//	if(i < 32){
//		*success = true;
//		return gpr(i);
//	}
//	else{
//		*success = false;
//	}
  return 0;
}
