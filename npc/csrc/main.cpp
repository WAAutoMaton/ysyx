#include "VTopLevel.h"
#include "common.h"
#include "difftest/difftest-def.h"
#include "dpi.h"
#include "isa/isa.h"
#include "sdb/sdb.h"
#include <assert.h>
#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <verilated.h>

int cycle_cnt;
int last_pc = 0;
int ftrace_inst;
int ftrace_rd;
int ftrace_pc;
#ifdef CONFIG_DIFFTEST
int difftest_inst;
int difftest_pc;
#endif

void cpu_exec(int n) {
  if (n < 0) {
    n = 0x3fffffff;
  }
  for (int i = 0; i < n; i++) {
    if (npc_status != NPC_STATUS_GOOD) {
      break;
    }
    cycle_cnt++;
    contextp->timeInc(1);
    top->clock = 0;
    top->eval();
    top->clock = 1;
    top->eval();
    if (is_ebreak) {
      npc_status = NPC_STATUS_QUIT;
      printf("At %d cycle, ebreak called. Exited.\n", cycle_cnt);
      break;
    }
    if (ftrace_inst != 0 && top->io_mem_read_address != ftrace_pc) {
      ftrace_exec(ftrace_pc, top->io_mem_read_address, ftrace_rd,
                  (ftrace_inst & 0x7f) == 0x6f);
      ftrace_inst = 0;
    }
    if (top->io_mem_read_en) {
#ifdef CONFIG_DIFFTEST
      if (difftest_pc != 0 && difftest_pc!=top->io_mem_read_address) {
        difftest_step(difftest_pc, top->io_mem_read_address);
      }
	  difftest_pc = top->io_mem_read_address;
#endif
      printf("Read %x\n", top->io_mem_read_address);
      top->io_mem_read_value = vaddr_read(top->io_mem_read_address, 4);
      uint32_t instr = top->io_mem_read_value;
      instruction_ring_buffer_push(top->io_mem_read_value, instr);
      // Is jal/jalr
      if ((instr & 0x7f) == 0x6f || (instr & 0x7f) == 0x67) {
        ftrace_inst = instr;
        ftrace_rd = (instr >> 7) & 0x1f;
        ftrace_pc = top->io_mem_read_address;
      }
    }
  }
}

int main(int argc, char **argv) {
  if (argc < 5) {
    puts("Format: <x.exe> +trace <executable image> <elf file> <difftest ref "
         "so file>");
    return 1;
  }
  Verilated::mkdir("logs");
  log_init();
  FILE *f = fopen(argv[2], "rb");
  if (f == nullptr) {
    puts("Open executable image failed");
  }
  const char *elf = argv[3];
  const char *difftest_ref_so_file = argv[4];
  int img_size = fread(mem, 1, MEM_SIZE, f);
  is_ebreak = false;
  contextp->debug(0);
  contextp->randReset(2);
  contextp->traceEverOn(true);
  contextp->commandArgs(argc, argv);
  top->reset = 1;
  top->clock = 0;
  top->eval();
  top->clock = 1;
  top->eval();
  top->reset = 0;
  npc_status = NPC_STATUS_GOOD;

  init_isa();
  init_sdb(elf);
#ifdef CONFIG_DIFFTEST
  init_difftest(difftest_ref_so_file, img_size, 0);
#endif

  sdb_mainloop();

  instruction_ring_buffer_write();
  ftrace_close();

  top->final();
  contextp->coveragep()->write("logs/coverage.dat");
  if (npc_status != NPC_STATUS_QUIT) {
    puts("Program exited abnormally.");
    log_close();
    return 1;
  }

  log_close();
}
