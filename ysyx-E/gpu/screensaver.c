#include <am.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <klib-macros.h>
#include <assert.h>

#define TILE_W 50
#define TILE_H 30

uint32_t board[8] = {0x000000, 0xff0000, 0x00ff00, 0x0000ff, 0xffff00, 0xff00ff, 0x00ffff, 0xffffff};

static uint32_t screen_h;
void draw(uint32_t color) {
    screen_h = io_read(AM_GPU_CONFIG).height / TILE_H;
    uint32_t buf[TILE_W * TILE_H];
    for(int i = 0; i < TILE_W * TILE_H; i++){
        buf[i] = color;
    }
    uint32_t x, y;
    x = y = 0;
    for(x = 0; x < screen_h; x++){
        for(y = 0; y < screen_h; y++){
            io_write(AM_GPU_FBDRAW, x * TILE_W, y * TILE_H, buf, TILE_W, TILE_H, false);
            io_write(AM_GPU_FBDRAW, 0, 0, NULL, 0, 0, true);
        }
    };
}

int main() {
  ioe_init(); // initialization for GUI
  int old_time = io_read(AM_TIMER_UPTIME).us / 1000;
  int t = 0;
  int wait_time = 900;
  while (1) {
    int now_time = io_read(AM_TIMER_UPTIME).us / 1000;
    AM_INPUT_KEYBRD_T ev = io_read(AM_INPUT_KEYBRD);
    if (ev.keydown == true && ev.keycode != AM_KEY_NONE) {
        if(ev.keycode == AM_KEY_ESCAPE) return 0;
        else wait_time = wait_time / 2; 
    }
    if(ev.keydown == false) wait_time = 900;
    if((now_time- old_time) > wait_time){
        printf("now_time = %d\n", now_time);
        printf("board[%d]= 0x%08x\n", t, board[t]);
        draw(board[t]);
        t = (t + 1) % 8;
        old_time = now_time;
    }
  }
  return 0;
}

