#pragma once

#include "VTopLevel.h"
#include <verilated.h>
#include "../common.h"

constexpr int MEM_SIZE=1024*1024;
extern uint32_t mem[MEM_SIZE];

extern const std::unique_ptr<VerilatedContext> contextp;
extern const std::unique_ptr<VTopLevel> top;

void isa_reg_display();
void init_isa();
word_t isa_reg_str2val(const char *s, bool *success);
word_t paddr_read(paddr_t addr, int len);
word_t vaddr_read(paddr_t addr, int len);