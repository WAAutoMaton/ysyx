#include "isa.h"
#include <stdint.h>
#include "../common.h"

const char *regs[] = {
  "$0", "ra", "sp", "gp", "tp", "t0", "t1", "t2",
  "s0", "s1", "a0", "a1", "a2", "a3", "a4", "a5",
  "a6", "a7", "s2", "s3", "s4", "s5", "s6", "s7",
  "s8", "s9", "s10", "s11", "t3", "t4", "t5", "t6"
};


uint8_t mem[MEM_SIZE];
const std::unique_ptr<VerilatedContext> contextp{new VerilatedContext};
const std::unique_ptr<VysyxSoCFull> top{new VysyxSoCFull{contextp.get(), "TOP"}};
unsigned char *imem_en_ref = nullptr;

void init_isa()
{
}

void isa_reg_display()
{
  CPU_state cpu = get_current_cpu_state(); 
  puts("Registers:");
  printf(" PC: 0x%08x\n", cpu.pc);
  for(int i = 0; i < 32; i++) {
      printf("%3s: 0x%08x %12d\n", regs[i], cpu.gpr[i], (int)cpu.gpr[i]);
  }
  puts("CSRs:");
  printf("mstatus: 0x%08x\n", cpu.mstatus);
  printf("mepc: 0x%08x\n", cpu.mepc);
  printf("mcause: 0x%08x\n", cpu.mcause);
  printf("mtvec: 0x%08x\n", cpu.mtvec);
  printf("mvendorid: 0x%08x\n", cpu.mvendorid);
  printf("marchid: 0x%08x\n", cpu.marchid);
}

word_t isa_reg_str2val(const char *s, bool *success) {
  CPU_state cpu = get_current_cpu_state();
  for(int i = 0; i < 32; i++) {
    if(strcmp(regs[i], s) == 0) {
      *success = true;
      return cpu.gpr[i];
    }
  }
  *success = false;
  return 0;
}

word_t paddr_read(paddr_t addr, int len)
{
    if (addr < CONFIG_MBASE || addr >= CONFIG_MBASE + MEM_SIZE) {
        //puts("Invalid memory access");
#ifdef CONFIG_MTRACE
  log_write("paddr_read: addr = " FMT_PADDR ", len = %d, data = INVALID\n", addr, len);
#endif
        return 0;
    }
    word_t result = 0;
    switch (len) {
        case 1:
            result= *guest_to_host(addr);
            break;
        case 2:
            result= *(uint16_t *)guest_to_host(addr);
            break;
        case 4:
            result= *(uint32_t *)guest_to_host(addr);
            break;
        default:
#ifdef CONFIG_MTRACE
            log_write("paddr_read: addr = " FMT_PADDR ", len = %d, data = INVALID\n", addr, len);
#endif
            return 0;
    }
#ifdef CONFIG_MTRACE
  log_write("paddr_read: addr = " FMT_PADDR ", len = %d, data = " FMT_WORD "\n", addr, len, result);
#endif
  return result;
}
word_t vaddr_read(paddr_t addr, int len)
{
    return paddr_read(addr, len);
}

void paddr_write(paddr_t addr, int wmask, word_t data)
{
#ifdef CONFIG_MTRACE
  log_write("paddr_write: addr = " FMT_PADDR ", wmask = %x, data = " FMT_WORD "\n", addr, wmask, data);
#endif
    if (addr < CONFIG_MBASE || addr >= CONFIG_MBASE + MEM_SIZE) {
        //puts("Invalid memory access");
        return;
    }
    for(int i = 0; i < 4; i++) {
        if(wmask & (1 << i)) {
            *guest_to_host(addr + i) = (data >> (i * 8)) & 0xff;
        }
    }
}

static inline bool in_pmem(paddr_t addr) {
  return addr - CONFIG_MBASE <= CONFIG_MSIZE && addr >= CONFIG_MBASE;
}
uint8_t* guest_to_host(paddr_t paddr) {   
  if (in_pmem(paddr)) {
    return mem + paddr - CONFIG_MBASE;
  }
  else {
    Log("paddr = " FMT_PADDR" is out of definition", paddr);
    return NULL;
  }
}
paddr_t host_to_guest(uint8_t *haddr) { return haddr - mem + CONFIG_MBASE; }

CPU_state current_cpu_state;

CPU_state get_current_cpu_state()
{
  return current_cpu_state;
}

bool isa_difftest_checkregs(CPU_state *ref_r, vaddr_t pc, vaddr_t npc) {
  auto cpu = get_current_cpu_state();
  bool result = true;
  if (ref_r->pc != npc) {
    printf("new pc is different at " FMT_WORD "! ref: " FMT_WORD
           ", NPC: " FMT_WORD "\n",
           pc, ref_r->pc, npc);
    result = false;
  }
  for (int i = 0; i < 32; i++) {
    if (ref_r->gpr[i] != cpu.gpr[i]) {
      printf("reg[%d] is different at pc = " FMT_WORD " ref: " FMT_WORD
             ",  NPC: " FMT_WORD "\n",
             i, pc, ref_r->gpr[i], cpu.gpr[i]);
      result = false;
    }
  }
  if (ref_r->mstatus != cpu.mstatus) {
    printf("mstatus is different at pc = " FMT_WORD " ref: " FMT_WORD
           ",  NPC: " FMT_WORD "\n",
           pc, ref_r->mstatus, cpu.mstatus);
    result = false;
  }
  if (ref_r->mepc != cpu.mepc) {
    printf("mepc is different at pc = " FMT_WORD " ref: " FMT_WORD
           ",  NPC: " FMT_WORD "\n",
           pc, ref_r->mepc, cpu.mepc);
    result = false;
  }
  if (ref_r->mcause != cpu.mcause) {
    printf("mcause is different at pc = " FMT_WORD " ref: " FMT_WORD
           ",  NPC: " FMT_WORD "\n",
           pc, ref_r->mcause, cpu.mcause);
    result = false;
  }
  if (ref_r->mtvec != cpu.mtvec) {
    printf("mtvec is different at pc = " FMT_WORD " ref: " FMT_WORD
           ",  NPC: " FMT_WORD "\n",
           pc, ref_r->mtvec, cpu.mtvec);
    result = false;
  }
  return result;
}