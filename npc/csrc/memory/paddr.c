#include <memory/host.h>
#include <memory/paddr.h>
//#include <utils.h>
//#include <device/mmio.h>
//#include <isa.h>

#if   defined(CONFIG_PMEM_MALLOC)
static uint8_t *pmem = NULL;
#else // CONFIG_PMEM_GARRAY
static uint8_t pmem[CONFIG_MSIZE] PG_ALIGN = {};
#endif

#ifdef CONFIG_MTRACE
extern int is_ifetch;
#endif

uint8_t* guest_to_host(paddr_t paddr) { return pmem + paddr - CONFIG_MBASE; }
paddr_t host_to_guest(uint8_t *haddr) { return haddr - pmem + CONFIG_MBASE; }

void pmem_load_img(FILE *fp){
	fseek(fp, 0, SEEK_END);
	long size = ftell(fp);
	fseek(fp, 0, SEEK_SET);

	size_t read_bytes = fread(pmem, 1, size, fp);
	if (read_bytes != size) {
    fprintf(stderr, "Read error: expected %ld bytes, got %zu\n", size, read_bytes);
  }
	return;
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
    default: MUXDEF(CONFIG_RT_CHECK, assert(0), return 0);break;
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

word_t paddr_read(paddr_t addr, int len) {
  if (likely(in_pmem(addr))) return pmem_read(addr, len);
  IFDEF(CONFIG_DEVICE, return mmio_read(addr, len));
  out_of_bound(addr);
  return 0;
}

void paddr_write(paddr_t addr, int len, word_t data) {
  if (likely(in_pmem(addr))) { pmem_write(addr, len, data); return; }
  IFDEF(CONFIG_DEVICE, mmio_write(addr, len, data); return);
  out_of_bound(addr);
}
