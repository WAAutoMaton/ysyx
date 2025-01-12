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

uint8_t *flash = NULL;
uint8_t *psram = NULL;
uint8_t *sram = NULL;
uint8_t *sdram = NULL;
extern "C" void init_flash(){
  flash = (uint8_t *)malloc(FLASH_SIZE);
  assert(flash);
  memset(flash, 0, FLASH_SIZE);
  for(int i=0; i<100; i++) {
    flash[i]=i*3;
  }
  Log("flash memory area [" FMT_PADDR ", " FMT_PADDR "]", FLASH_BASE, FLASH_BASE+FLASH_SIZE);
};

extern "C" void init_sram() {
  sram = (uint8_t *)malloc(SRAM_SIZE);
  assert(sram);
  memset(sram, 0, SRAM_SIZE);
  Log("sram memory area [" FMT_PADDR ", " FMT_PADDR "]", SRAM_BASE, SRAM_BASE+SRAM_SIZE);
};

extern "C" void init_sdram() {
  sdram = (uint8_t *)malloc(SDRAM_SIZE);
  assert(sdram);
  memset(sdram, 0, SDRAM_SIZE);
  Log("sdram memory area [" FMT_PADDR ", " FMT_PADDR "]", SDRAM_BASE, SDRAM_BASE+SDRAM_SIZE);
};


extern "C" void init_psram() {
  psram = (uint8_t *)malloc(PSRAM_SIZE);
  assert(psram);
  memset(psram, 0, PSRAM_SIZE);
  Log("psram memory area [" FMT_PADDR ", " FMT_PADDR "]", PSRAM_BASE, PSRAM_BASE+PSRAM_SIZE);
}
extern "C" void flash_read(int32_t addr, int32_t *data) { 
  int align_addr = addr + FLASH_BASE;
  *data = ((uint32_t*)flash)[addr/4];
  Log("%d %d\n",addr, *data);
}

extern "C" void mrom_read(int32_t addr, int32_t *data) { 
  //*data = 0b00000000000100000000000001110011;
  *data = ((uint32_t*)mem)[(addr-0x20000000L)/4];
}
int cycle_cnt;
extern uint32_t *reg_ref[32];
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
      if (*reg_ref[1]==0) {
        npc_status = NPC_STATUS_QUIT;
        printf("At %d cycle, ebreak called. Exited.\n", cycle_cnt);
      } else {
        npc_status = NPC_STATUS_FAILED;
        printf("At %d cycle, ebreak called with error code %d. Exited.\n", cycle_cnt, int(*reg_ref[1]));
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
  init_psram();
  init_flash();
  init_sram();
  init_sdram();
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
