#ifndef EBREAK_H
#define EBREAK_H

extern int end_sim;
extern bool is_good_trap;
extern uint32_t ebreak_pc;
extern uint32_t ebreak_snpc;
extern uint32_t ebreak_dnpc;
extern uint32_t ebreak_inst;
extern uint32_t ebreak_rd  ;
extern uint32_t ebreak_rs1 ;
extern uint32_t is_jal ;
extern uint32_t is_jalr;
void is_ebreak(uint32_t ebreak, uint32_t a0, uint32_t pc, uint32_t snpc, uint32_t dnpc, uint32_t inst, uint32_t rd, uint32_t rs1, uint32_t jal, uint32_t jalr);

#endif
