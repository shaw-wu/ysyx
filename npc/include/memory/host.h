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

#ifndef __MEMORY_HOST_H__
#define __MEMORY_HOST_H__

#include <common.h>

static inline word_t host_read(void *addr, int len) {
	word_t rdata =  *(uint32_t *)addr;
	switch ((long)addr % 4) {
		case 0x0: rdata = rdata; break;
		case 0x1: rdata <<= 8 ; break;
		case 0x2: rdata <<= 16; break;
		case 0x3: rdata <<= 24; break;
		default : break;
	}
  switch (len) {
    case 1: return rdata;
    case 2: return rdata;
    case 4: return rdata;
    IFDEF(CONFIG_ISA64, case 8: return *(uint64_t *)addr);
    default: MUXDEF(CONFIG_RT_CHECK, assert(0), return 0);
  }
  //switch (len) {
  //  case 1: return *(uint8_t  *)addr;
  //  case 2: return *(uint16_t *)addr;
  //  case 4: return *(uint32_t *)addr;
  //  IFDEF(CONFIG_ISA64, case 8: return *(uint64_t *)addr);
  //  default: MUXDEF(CONFIG_RT_CHECK, assert(0), return 0);
  //}
}

static inline void host_write(void *addr, int len, word_t data) {
	switch ((long)addr % 4) {
		case 0x0: data = data; break;
		case 0x1: data >>= 8 ; break;
		case 0x2: data >>= 16; break;
		case 0x3: data >>= 24; break;
		default : break;
	}
  switch (len) {
    case 1: *(uint8_t  *)addr = data; return;
    case 2: *(uint16_t *)addr = data; return;
    case 4: *(uint32_t *)addr = data; return;
    IFDEF(CONFIG_ISA64, case 8: *(uint64_t *)addr = data; return);
    IFDEF(CONFIG_RT_CHECK, default: assert(0));
  }
}

#endif
