#pragma once

#include "VTopLevel.h"
#include <verilated.h>
#include "../common.h"
#include "../config.h"


constexpr int MEM_SIZE=1024*1024*4;
extern uint8_t mem[MEM_SIZE];

extern const std::unique_ptr<VerilatedContext> contextp;
extern const std::unique_ptr<VTopLevel> top;
extern unsigned char* imem_en_ref;

extern "C" struct riscv32_CPU_state{
  word_t gpr[32];
  vaddr_t pc;
};

using CPU_state = riscv32_CPU_state;


void isa_reg_display();
void init_isa();
word_t isa_reg_str2val(const char *s, bool *success);
word_t paddr_read(paddr_t addr, int len);
word_t vaddr_read(paddr_t addr, int len);
void paddr_write(paddr_t addr, int len,word_t data);
uint8_t* guest_to_host(paddr_t paddr);
paddr_t host_to_guest(uint8_t *haddr);
CPU_state get_current_cpu_state();
bool isa_difftest_checkregs(CPU_state *ref_r, vaddr_t pc, vaddr_t npc);