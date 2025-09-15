#include <memory/host.h>
#include <memory/paddr.h>
#include <assert.h>

static uint8_t pmem[CONFIG_MSIZE] PG_ALIGN = {};

#ifdef CONFIG_MTRACE
extern int is_ifetch;
#endif

uint8_t* guest_to_host(paddr_t paddr) { return pmem + paddr - CONFIG_MBASE; }
paddr_t host_to_guest(uint8_t *haddr) { return haddr - pmem + CONFIG_MBASE; }

long load_img(FILE *fp){
	fseek(fp, 0, SEEK_END);
	long size = ftell(fp);
	fseek(fp, 0, SEEK_SET);

	size_t read_bytes = fread(pmem, 1, size, fp);
	if (read_bytes != size) {
    fprintf(stderr, "Read error: expected %ld bytes, got %zu\n", size, read_bytes);
  }
	return size;
}

static word_t pmem_read(paddr_t addr, int len) {
  word_t ret = host_read(guest_to_host(addr), len);
#ifdef CONFIG_MTRACE
	if(is_ifetch){
		is_ifetch = 0;
	} else {
		switch(len){
			case 1: printf(ANSI_FMT("[pmem_read ]", ANSI_FG_CYAN) " addr: 0x%08x   rdata: 0x%02x\n", addr, ret);break;
			case 2: printf(ANSI_FMT("[pmem_read ]", ANSI_FG_CYAN) " addr: 0x%08x   rdata: 0x%04x\n", addr, ret);break;
			case 4: printf(ANSI_FMT("[pmem_read ]", ANSI_FG_CYAN) " addr: 0x%08x   rdata: 0x%08x\n", addr, ret);break;
    	IFDEF(CONFIG_ISA64, case 8: printf(ANSI_FMT("[pmem_read ]", ANSI_FG_CYAN) " addr: 0x%08x   rdata: 0x%016x\n", addr, ret));break;
    	default: MUXDEF(CONFIG_RT_CHECK, assert(0), return 0);break;
		}
	}
#endif
  return ret;
}

static void pmem_write(paddr_t addr, int len, word_t data) {
#ifdef CONFIG_MTRACE
	switch(len){
		case 1: printf(ANSI_FMT("[pmem_write]", ANSI_FG_CYAN) " addr: 0x%08x   wdata: 0x%02x\n", addr, data);break;
		case 2: printf(ANSI_FMT("[pmem_write]", ANSI_FG_CYAN) " addr: 0x%08x   wdata: 0x%04x\n", addr, data);break;
		case 4: printf(ANSI_FMT("[pmem_write]", ANSI_FG_CYAN) " addr: 0x%08x   wdata: 0x%08x\n", addr, data);break;
    IFDEF(CONFIG_ISA64, case 8: printf(ANSI_FMT("[pmem_write]", ANSI_FG_CYAN) " addr: 0x%08x   wdata: 0x%016x\n", addr, data));break;
    default: MUXDEF(CONFIG_RT_CHECK, assert(0), return);break;
	}
#endif
  host_write(guest_to_host(addr), len, data);
}

void out_of_bound(paddr_t addr) {
  //panic("address = " FMT_PADDR " is out of bound of pmem [" FMT_PADDR ", " FMT_PADDR "] at pc = " FMT_WORD,
  //    addr, PMEM_LEFT, PMEM_RIGHT, cpu.pc);
  panic("address = " FMT_PADDR " is out of bound of pmem [" FMT_PADDR ", " FMT_PADDR "]",
      addr, PMEM_LEFT, PMEM_RIGHT);
}

void init_mem() {
#if   defined(CONFIG_PMEM_MALLOC)
  pmem = malloc(CONFIG_MSIZE);
  assert(pmem);
#endif
  IFDEF(CONFIG_MEM_RANDOM, memset(pmem, rand(), CONFIG_MSIZE));
  printf(ANSI_FMT("physical memory area [" FMT_PADDR ", " FMT_PADDR "]", ANSI_FG_BLUE) "\n", PMEM_LEFT, PMEM_RIGHT);
  //Log("physical memory area [" FMT_PADDR ", " FMT_PADDR "]", PMEM_LEFT, PMEM_RIGHT);
}

static uint64_t now_time;
word_t mmio_read(paddr_t addr, int len) {
	word_t ret;
	if(addr >= TIMER_ADDR && addr < TIMER_END){
		if(addr == TIMER_ADDR + 4) {
			now_time = get_time();
			ret = now_time >> 32;
		} else {
			ret = now_time;
		}
	} else {
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
	if(addr >= SERIAL_ADDR && addr < SERIAL_END){
		if(addr == SERIAL_ADDR) {
			putc((char)data, stderr);
		} else {
			printf("Serial read don't implement.\n");
		}
	} else {
		printf("Device addr : 0x%0x can't find", addr);
	}
}
word_t paddr_read(paddr_t addr, int len) {
  if (likely(in_pmem(addr))) return pmem_read(addr, len);
	return mmio_read(addr, len);
}

void paddr_write(paddr_t addr, int len, word_t data) {
  if (likely(in_pmem(addr))) { pmem_write(addr, len, data); return; }
  mmio_write(addr, len, data);
	return;
}

