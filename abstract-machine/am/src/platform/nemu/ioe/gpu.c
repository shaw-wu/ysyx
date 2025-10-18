#include <am.h>
#include <nemu.h>
#include <stdio.h>
#include <assert.h>

#define SYNC_ADDR (VGACTL_ADDR + 4)

uint32_t width = 0;
uint32_t height = 0;
uint32_t size = 0;

void __am_gpu_init() {
	uint32_t vgactl_0 = inl(VGACTL_ADDR);
	width = (vgactl_0 >> 16) & 0x0000ffff;
	height = vgactl_0 & 0x0000ffff;
	size = width * height * sizeof(uint32_t); 

	//int i;
	//int w = width;
	//int h = height;
	//uint32_t *fb = (uint32_t *)(uintptr_t)FB_ADDR;
	//for(i = 0; i < w * h; i ++) fb[i] = i;
	//outl(SYNC_ADDR, 1);
}

void __am_gpu_config(AM_GPU_CONFIG_T *cfg) {
  *cfg = (AM_GPU_CONFIG_T) {
    .present = true, .has_accel = false,
    .width = (int)width, .height = (int)height,
    .vmemsz = (int)size
  };
}

void __am_gpu_fbdraw(AM_GPU_FBDRAW_T *ctl) {
	if(ctl->pixels != NULL){
		uint32_t pix;
		for(int j = 0; j < ctl->h; j ++){
			for(int i = 0; i < ctl->w; i++){
				pix = *((uint32_t *)ctl->pixels + j * ctl->w + i);
				outl(FB_ADDR + ((ctl->y + j) * width + (ctl->x + i)) * 4, pix);
			}
		}
	}
  if (ctl->sync) {
    outl(SYNC_ADDR, ctl->sync);
  }
}

void __am_gpu_status(AM_GPU_STATUS_T *status) {
  status->ready = true;
}
