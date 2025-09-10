//#include <isa.h>
#include <svdpi.h>
#include <Vysyx_25010009_top__Dpi.h>
#include <memory/paddr.h>

#ifdef CONFIG_MTRACE
int is_ifetch = 0;	
#endif

word_t vaddr_ifetch(vaddr_t addr, int len, int ren) {
	if(!ren) return 0;
#ifdef CONFIG_MTRACE
	is_ifetch = 1;
#endif
  return paddr_read(addr, len);
}

word_t vaddr_read(vaddr_t addr, int len) {
  return paddr_read(addr, len);
}

void vaddr_write(vaddr_t addr, int len, word_t data) {
  paddr_write(addr, len, data);
}

word_t dpi_vaddr_read(vaddr_t addr, int len, int ren) {
	if(!ren) return 0;
  return paddr_read(addr, len);
}

void dpi_vaddr_write(vaddr_t addr, int len, word_t data, int wen) {
	if(!wen) return;
  paddr_write(addr, len, data);
}
