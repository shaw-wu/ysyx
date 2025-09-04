#ifndef EBREAK_H
#define EBREAK_H

extern int stop_sim;
extern bool is_good_trap;
extern uint32_t ebreak_pc;
void is_ebreak(int ebreak, int a0, int pc);

#endif
