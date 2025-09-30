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
#include <memory/paddr.h>

/* 内置客户程序(isa) wxz*/
// this is not consistent with uint8_t
// but it is ok since we do not access the array directly
static const uint32_t img [] = {
  0x00000297,  // auipc t0,0
	//0x01100313,  // addi t1, zero, 17
	//0x406282b3,  // sub t0, t0, t1
  0x00028823,  // sb  zero,16(t0)
  0x0102c503,  // lbu a0,16(t0)
  0x00100073,  // ebreak (used as nemu_trap)
  0xdeadbeef,  // some data
};

static void restart() {
  /* Set the initial program counter. */
	memset(cpu.csrs_valid, 0, sizeof(cpu.csrs_valid));
	cpu.csrs_valid[MSTATUS  ] = 1;
	cpu.csrs_valid[MTVEC	  ] = 1;
	cpu.csrs_valid[MEPC		  ] = 1;
	cpu.csrs_valid[MCAUSE   ] = 1;
	cpu.csrs_valid[MCYCLE   ] = 1;
	cpu.csrs_valid[MVENDORID] = 1;
	cpu.csrs_valid[MARCHID	] = 1;
  cpu.pc = RESET_VECTOR;
	cpu.csrs[MSTATUS] = 0x1800;
<<<<<<< HEAD
=======
	cpu.csrs[MVENDORID] = 0x79737978;
	cpu.csrs[MARCHID] = 0x17d9f59;
>>>>>>> tracer-ysyx

  /* The zero register is always 0. */
  cpu.gpr[0] = 0;
}

void init_isa() {
  /* Load built-in image. */
  memcpy(guest_to_host(RESET_VECTOR), img, sizeof(img));

  /* Initialize this virtual computer system. */
  restart();
}
