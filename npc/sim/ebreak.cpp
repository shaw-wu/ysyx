#include <svdpi.h>
#include <VysyxSoCFull__Dpi.h>
#include <isa.h>
#include <stdio.h>

void is_ebreak(uint32_t ebreak, uint32_t pc, uint32_t snpc, uint32_t dnpc, uint32_t inst, uint32_t rd, uint32_t rs1, uint32_t jal, uint32_t jalr){
	svScope scope = svGetScopeFromName("TOP.ysyx_25010009_top.GPR");
  if (!scope) {
      fprintf(stderr, "Error: Cannot find DPI scope!\n");
      exit(1);
  }
  svSetScope(scope);
	cpu.pc   = pc  ;
	cpu.snpc = snpc;
	cpu.dnpc = dnpc;
	decode.inst.val = inst;
	decode.rd   = rd  ;
	decode.rs1  = rs1 ;
	decode.is_jal  = jal ;
	decode.is_jalr = jalr;
	for(int i = 0; i < MUXDEF(CONFIG_RVE, 16, 32); i++){
		word_t gpr_x = 0;
		read_gpr(i, &gpr_x);
		cpu.gpr[i] = gpr_x; 
	}
	for(int i = 0; i < 4096; i++){
		if(cpu.csrs_valid[i]) {
			word_t csr_x = 0;
			read_csr(i, &csr_x);
			cpu.csrs[i] = csr_x;
		}
	}
  if(ebreak) {
		end_sim = 1;
		if(cpu.gpr[10] == 0) is_good_trap = true;
	}
	return;
}
