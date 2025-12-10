#include <memory/paddr.h>
#include <device/mmio.h>

static uint64_t now_time;
word_t mmio_read(paddr_t addr, int len) {
	word_t ret = 0;
	if(no_devices){
		printf("Has no devices config.\n");
	}
#if CONFIG_HAS_TIMER
	else if(addr >= CONFIG_RTC_MMIO && addr < CONFIG_RTC_MMIO+8){
#ifdef CONFIG_DIFFTEST
		access_device = true;
#endif
		if(addr == CONFIG_RTC_MMIO + 4) {
			now_time = get_time();
			ret = now_time >> 32;
		} else {
			ret = now_time;
		}
	}
#endif
	else {
		printf("Device addr : 0x%0x can't find.\n", addr);
	}
//#ifdef CONFIG_DTRACE
//	switch(len){
//		case 1: printf(ANSI_FMT("[device_read ]", ANSI_FG_CYAN) " device: %s addr: 0x%08x   rdata: 0x%02x\n", name, addr, ret);break;
//		case 2: printf(ANSI_FMT("[device_read ]", ANSI_FG_CYAN) " device: %s addr: 0x%08x   rdata: 0x%04x\n", name, addr, ret);break;
//		case 4: printf(ANSI_FMT("[device_read ]", ANSI_FG_CYAN) " device: %s addr: 0x%08x   rdata: 0x%08x\n", name, addr, ret);break;
//    IFDEF(CONFIG_ISA64, case 8: printf(ANSI_FMT("[pmem_read ]", ANSI_FG_CYAN) " device: %s addr: 0x%08x   rdata: 0x%016x\n", name, addr, ret));break;
//    default: MUXDEF(CONFIG_RT_CHECK, assert(0), return 0);break;
//	}
//#endif
  return ret;
}


void mmio_write(paddr_t addr, int len, word_t data) {
//#ifdef CONFIG_DTRACE
//	switch(len){
//		case 1: printf(ANSI_FMT("[device_write]", ANSI_FG_CYAN) " device: %s addr: 0x%08x   wdata: 0x%02x\n", name, addr, data);break;
//		case 2: printf(ANSI_FMT("[device_write]", ANSI_FG_CYAN) " device: %s addr: 0x%08x   wdata: 0x%04x\n", name, addr, data);break;
//		case 4: printf(ANSI_FMT("[device_write]", ANSI_FG_CYAN) " device: %s addr: 0x%08x   wdata: 0x%08x\n", name, addr, data);break;
//    IFDEF(CONFIG_ISA64, case 8: printf(ANSI_FMT("[pmem_write]", ANSI_FG_CYAN) " device: %s addr: 0x%08x   wdata: 0x%016x\n", name, addr, data));break;
//    default: MUXDEF(CONFIG_RT_CHECK, assert(0), return 0);break;
//	}
//#endif
	if(no_devices){
		printf("Has no devices config.\n");
	}
#if CONFIG_HAS_SERIAL
	else if(addr >= CONFIG_SERIAL_MMIO && addr < CONFIG_SERIAL_MMIO+8){
#ifdef CONFIG_DIFFTEST
		access_device = true;
#endif
		if(addr == CONFIG_SERIAL_MMIO) {
			putc((char)data, stderr);
		} else {
			printf("Serial read don't implement.\n");
		}
	}
#endif
	else {
		printf("Device addr : 0x%08x can't find", addr);
	}
}
