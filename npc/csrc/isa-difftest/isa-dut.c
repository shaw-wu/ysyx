/***************************************************************************************
* Copyright (c) 2014-2022 Zihao Yu, Nanjing University
*
* NEMU is licensed under Mulan PSL v2.
* You can use this software according to the terms and conditions of the Mulan PSL v2.
* You may obtain a copy of Mulan PSL v2 at:
*          http://license.coscl.org.cn/MulanPSL2
*
* THIS SOFTWARE IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
* EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
* MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
*
* See the Mulan PSL v2 for more details.
***************************************************************************************/

#include <isa.h>
//#include <difftest.h>
//#include "reg.h"

extern const char *regs[];

void ref_reg_display(CPU_state *ref_r) {
	int i, j;
	i = 0;
	for(j = 0; j < 4; j++){
		for(; i < (j + 1) * 4; i++){
			if(strcmp(regs[i], "s10") == 0 || strcmp(regs[i], "s11") == 0) {
				printf("%s : 0x%-15x", regs[i], ref_r->gpr[i]);
			}
			else {
				printf("%s  : 0x%-15x", regs[i], ref_r->gpr[i]);
			}
	}
		printf("\n");
	}
	return;
}

bool isa_difftest_checkregs(CPU_state *ref_r, vaddr_t pc) {
	int i = 0;
	while(1){
		if(ref_r->pc != pc) break;
		for(i = 0; i < MUXDEF(CONFIG_RVE, 16, 32); i++){
		  if(ref_r->gpr[i]	!= cpu.gpr[i]) {
			  break;
			}
		}
		if(i != MUXDEF(CONFIG_RVE, 16, 32)) break;
		return true;
	}
	printf("dut_pc: 0x%08x, ref_pc: 0x%08x\n", pc, ref_r->pc);
	printf("dut: %s = 0x%08x, ref: %s = 0x%08x\n", regs[i], cpu.gpr[i], regs[i], ref_r->gpr[i]); 
	printf("ref gpr:\n");
	ref_reg_display(ref_r);	
  return false;
}

void isa_difftest_attach() {
}
