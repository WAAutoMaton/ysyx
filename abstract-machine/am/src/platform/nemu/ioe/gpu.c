#include <am.h>
#include <nemu.h>

#define SYNC_ADDR (VGACTL_ADDR + 4)

void __am_gpu_init() {
  int i;
  uint32_t screen_wh = inl(VGACTL_ADDR);
  int w = screen_wh >> 16, h = screen_wh & 0xffff;
  uint32_t *fb = (uint32_t *)(uintptr_t)FB_ADDR;
  for (i = 0; i < w * h; i ++) fb[i] = i;
  outl(SYNC_ADDR, 1);
}

void __am_gpu_config(AM_GPU_CONFIG_T *cfg) {
  uint32_t screen_wh = inl(VGACTL_ADDR); // from vga.c:init_vga(), vgactl_port_base[0]
  *cfg = (AM_GPU_CONFIG_T) {
    .present = true, .has_accel = false,
    .width = screen_wh>>16, .height = screen_wh & 0xffff,
    .vmemsz = 0
  };
}

void __am_gpu_fbdraw(AM_GPU_FBDRAW_T *ctl) {
  int x=ctl->x, y=ctl->y;
  int w=ctl->w, h=ctl->h;
  uint32_t *buffer = (uint32_t*)FB_ADDR;
  int W = inl(VGACTL_ADDR) >> 16;
  for(int i=0; i<h; i++) {
    for(int j=0; j<w; j++) {
      buffer[(y+i)*W + x+j] = ((uint32_t *)ctl->pixels)[i*w+j];
    }
  }
  if (ctl->sync) {
    outl(SYNC_ADDR, 1); // vga.c, vgactl_port_base[1]
  }
}

void __am_gpu_status(AM_GPU_STATUS_T *status) {
  status->ready = true;
}
