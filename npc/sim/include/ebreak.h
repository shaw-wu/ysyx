#ifndef EBREAK_H
#define EBREAK_H

extern int end_sim;
extern bool is_good_trap;
extern uint32_t ebreak_pc;
extern uint32_t ebreak_snpc;
extern uint32_t ebreak_inst;
void is_ebreak(uint32_t ebreak, uint32_t a0, uint32_t pc, uint32_t snpc, uint32_t inst);

#endif
