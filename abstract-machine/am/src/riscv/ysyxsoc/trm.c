#include <am.h>
#include <klib-macros.h>
#include "include/ysyxsoc.h"
#include "../riscv.h"

extern char _heap_start;
int main(const char *args);

extern char _pmem_start;
#define HEAP_SIZE 0x1000
#define HEAP_END  ((uintptr_t)&_heap_start + HEAP_SIZE)

#define SRAM_START 0x0f000000
#define SRAM_SIZE 0x1fff

Area heap = RANGE(&_heap_start, HEAP_END);
#ifndef MAINARGS
#define MAINARGS ""
#endif
static const char mainargs[] = MAINARGS;

#define UART_BASE 0x10000000L
#define UART_TX   0

void putch(char ch) {
  *(volatile char *)(UART_BASE + UART_TX) = ch;
}

void halt(int code) {
  __asm__("add x1, x0, %0\n" : : "r"(code));
  __asm__("ebreak");
  while (1);
}

void bootloader() {
  extern char _data_start, _data_end, _m_data_start;
  extern char _bss_start, _bss_end;
  //halt(&_data_end - &_data_start + 1000);

  char* p = &_m_data_start;
  for(char* i=&_data_start; i<&_data_end; i++, p++) {
    *i = *p;
  }
  for(char* i=&_bss_start; i<&_bss_end; i++) {
    *i = 0;
  }
}

void _trm_init() {
  bootloader();
  int ret = main(mainargs);
  halt(ret);
}
