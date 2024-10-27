#include "VysyxSoCFull.h"
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

extern "C" void flash_read(int32_t addr, int32_t *data) { assert(0); }
extern "C" void mrom_read(int32_t addr, int32_t *data) { 
  //*data = 0b00000000000100000000000001110011;
  *data = ((uint32_t*)mem)[(addr-0x20000000L)/4];
  //printf("MROM READ, address: %x, data: %x\n", addr, *data);
}

int cycle_cnt;

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
      if (ebreak_code==1) {
        npc_status = NPC_STATUS_QUIT;
        printf("At %d cycle, ebreak called. Exited.\n", cycle_cnt);
      } else {
        npc_status = NPC_STATUS_FAILED;
        printf("At %d cycle, ebreak called with error code %d. Exited.\n", cycle_cnt, int(ebreak_code));
      }
      break;
    }
  }
}

int main(int argc, char **argv) {
  if (argc < 5) {
    puts("Format: <x.exe> +trace batch-on/batch-off <executable image> <elf file> <difftest ref "
         "so file>");
    return 1;
  }
  Verilated::commandArgs(argc, argv);
  Verilated::mkdir("logs");
  log_init();
  if (strcmp(argv[2], "batch-on") == 0) {
    Log("Batch mode on");
    sdb_set_batch_mode();
  } else {
    Log("Batch mode off");
  }
  FILE *f = fopen(argv[3], "rb");
  if (f == nullptr) {
    puts("Open executable image failed");
  }
  const char *elf = argv[4];
  const char *difftest_ref_so_file = argv[5];
  int img_size = fread(mem, 1, MEM_SIZE, f);
  is_ebreak = false;
  contextp->debug(0);
  contextp->randReset(2);
  contextp->traceEverOn(true);
  contextp->commandArgs(argc, argv);
  //imem_en_ref = &top->io_test_imem_en;
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
  init_difftest(difftest_ref_so_file, img_size, mem, 0);
#endif

  get_time();
  sdb_mainloop();

#ifdef CONFIG_ITRACE
  instruction_ring_buffer_write();
#endif
#ifdef CONFIG_FTRACE
  ftrace_close();
#endif

  top->final();
  contextp->coveragep()->write("logs/coverage.dat");
  if (npc_status != NPC_STATUS_QUIT) {
    puts("Program exited abnormally.");
    log_close();
    return 1;
  }

  log_close();
}
