#include <am.h>
#include <klib-macros.h>
#include <npc.h>
//#include <stdio.h>

extern char _heap_start;
int main(const char *args);

extern char _pmem_start;
#define PMEM_SIZE (128 * 1024 * 1024)
#define PMEM_END  ((uintptr_t)&_pmem_start + PMEM_SIZE)

Area heap = RANGE(&_heap_start, PMEM_END);
#ifndef MAINARGS
#define MAINARGS ""
#endif
//static const char mainargs[MAINARGS_MAX_LEN] = TOSTRING(MAINARGS_PLACEHOLDER); // defined in CFLAGS
static const char mainargs[MAINARGS_MAX_LEN] = MAINARGS; 

void putch(char ch) {
	uint8_t LSR = inb(SERIAL_PORT+0x05);
	while((LSR & 0x20) != 0x20){
		LSR = inb(SERIAL_PORT+0x05);
	}
	outb(SERIAL_PORT, ch);
}

void halt(int code) {
	__asm__ volatile("ebreak");
	while (1);
}

void set_uart_divisor(){
	outb(SERIAL_PORT+0x03, 0x83);
	outb(SERIAL_PORT+0x01, 0x00);	
	outb(SERIAL_PORT+0x00, 0x0d);	
	outb(SERIAL_PORT+0x03, 0x03);
	//outb(SERIAL_PORT, 'a');
	//outb(SERIAL_PORT, 'b');
}


void _trm_init() {
	//uint32_t mvendorid, marchid;
	//__asm__ volatile ("csrr %0, mvendorid" : "=r" (mvendorid));
	//__asm__ volatile ("csrr %0, marchid	 " : "=r" (marchid));
	//printf("mvendorid = %x, marchid = %u\n", mvendorid, marchid);
	//char vendor[5];
	//vendor[4] = '\0';
	//vendor[3] = (mvendorid >> 0)  & 0xFF;
	//vendor[2] = (mvendorid >> 8)  & 0xFF;
	//vendor[1] = (mvendorid >> 16) & 0xFF;
	//vendor[0] = (mvendorid >> 24) & 0xFF;
	//printf("my id = %s_%u\n", vendor, marchid);
	set_uart_divisor();
  int ret = main(mainargs);
  halt(ret);
}
