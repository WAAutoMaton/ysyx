#include "isa.h"
#include <stdint.h>
#include "../common.h"

const char *regs[] = {
  "$0", "ra", "sp", "gp", "tp", "t0", "t1", "t2",
  "s0", "s1", "a0", "a1", "a2", "a3", "a4", "a5",
  "a6", "a7", "s2", "s3", "s4", "s5", "s6", "s7",
  "s8", "s9", "s10", "s11", "t3", "t4", "t5", "t6"
};

uint32_t *reg_ref[32];

uint8_t mem[MEM_SIZE];
const std::unique_ptr<VerilatedContext> contextp{new VerilatedContext};
const std::unique_ptr<VTopLevel> top{new VTopLevel{contextp.get(), "TOP"}};
unsigned char *imem_en_ref = nullptr;

void init_isa()
{
    reg_ref[0] = &top->io_test_regs_0;
    reg_ref[1] = &top->io_test_regs_1;
    reg_ref[2] = &top->io_test_regs_2;
    reg_ref[3] = &top->io_test_regs_3;
    reg_ref[4] = &top->io_test_regs_4;
    reg_ref[5] = &top->io_test_regs_5;
    reg_ref[6] = &top->io_test_regs_6;
    reg_ref[7] = &top->io_test_regs_7;
    reg_ref[8] = &top->io_test_regs_8;
    reg_ref[9] = &top->io_test_regs_9;
    reg_ref[10] = &top->io_test_regs_10;
    reg_ref[11] = &top->io_test_regs_11;
    reg_ref[12] = &top->io_test_regs_12;
    reg_ref[13] = &top->io_test_regs_13;
    reg_ref[14] = &top->io_test_regs_14;
    reg_ref[15] = &top->io_test_regs_15;
    reg_ref[16] = &top->io_test_regs_16;
    reg_ref[17] = &top->io_test_regs_17;
    reg_ref[18] = &top->io_test_regs_18;
    reg_ref[19] = &top->io_test_regs_19;
    reg_ref[20] = &top->io_test_regs_20;
    reg_ref[21] = &top->io_test_regs_21;
    reg_ref[22] = &top->io_test_regs_22;
    reg_ref[23] = &top->io_test_regs_23;
    reg_ref[24] = &top->io_test_regs_24;
    reg_ref[25] = &top->io_test_regs_25;
    reg_ref[26] = &top->io_test_regs_26;
    reg_ref[27] = &top->io_test_regs_27;
    reg_ref[28] = &top->io_test_regs_28;
    reg_ref[29] = &top->io_test_regs_29;
    reg_ref[30] = &top->io_test_regs_30;
    reg_ref[31] = &top->io_test_regs_31;
}

void isa_reg_display()
{
    puts("Registers:");
    for(int i = 0; i < 32; i++) {
        printf("%3s: 0x%08x %12d\n", regs[i], *reg_ref[i], (int)*reg_ref[i]);
    }
}

word_t isa_reg_str2val(const char *s, bool *success) {
  for(int i = 0; i < 32; i++) {
    if(strcmp(regs[i], s) == 0) {
      *success = true;
      return *reg_ref[i];
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

uint8_t* guest_to_host(paddr_t paddr) { return mem + paddr - CONFIG_MBASE; }
paddr_t host_to_guest(uint8_t *haddr) { return haddr - mem + CONFIG_MBASE; }

CPU_state get_current_cpu_state()
{
    CPU_state cpu;
    for(int i = 0; i < 32; i++) {
        cpu.gpr[i] = *reg_ref[i];
    }
    cpu.pc = top->io_test_pc;
    cpu.mstatus = top->io_test_csr_0;
    cpu.mepc = top->io_test_csr_1;
    cpu.mcause = top->io_test_csr_2;
    cpu.mtvec = top->io_test_csr_3;
    return cpu;
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