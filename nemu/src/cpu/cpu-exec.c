/***************************************************************************************
* Copyright (c) 2014-2022 Zihao Yu, Nanjing University
*
* NEMU is licensed under Mulan PSL v2.
* You can use this software according to the terms and conditions of the Mulan PSL v2.
* You may obtain a copy of Mulan PSL v2 at:
*          http://license.coscl.org.cn/MulanPSL2
*
* THIS SOFTWARE IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
* EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
* MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
*
* See the Mulan PSL v2 for more details.
***************************************************************************************/

#include "debug.h"
#include "utils.h"
#include <cpu/cpu.h>
#include <cpu/decode.h>
#include <cpu/difftest.h>
#include <locale.h>
#include <elf.h>
#include <fcntl.h>
#include <unistd.h>
#include <sys/mman.h>
#include <sys/stat.h>

#ifdef CONFIG_WATCHPOINT
  #include "../monitor/sdb/watchpoint.h"
#endif

/* The assembly code of instructions executed is only output to the screen
 * when the number of instructions executed is less than this value.
 * This is useful when you use the `si' command.
 * You can modify this value as you want.
 */
#define MAX_INST_TO_PRINT 10

CPU_state cpu = {};
uint64_t g_nr_guest_inst = 0;
static uint64_t g_timer = 0; // unit: us
static bool g_print_step = false;

char instruction_ring_buffer[INSTRUCTION_LOG_BUF_SIZE][128];
int instruction_ring_buffer_head, instruction_ring_buffer_tail;
SymbolFunc *symbol_funcs;
int symbol_func_num;
void instruction_ring_buffer_init() {
  instruction_ring_buffer_head = 0;
  instruction_ring_buffer_tail = 0;
}
void instruction_ring_buffer_write() {
  for (int i = instruction_ring_buffer_head; i != instruction_ring_buffer_tail; (i==INSTRUCTION_LOG_BUF_SIZE-1)?i=0:i++) {
    log_write("%s\n", instruction_ring_buffer[i]);
  }
}

void ftrace_init(const char* elf_file) {
  if (elf_file == NULL) {
    Log("No ELF file is given. ftrace is disabled.");
    symbol_func_num=0;
    symbol_funcs=NULL;
    return;
  }
  Log("Reading ELF file %s", elf_file);
  int fd = open(elf_file, O_RDONLY);
  if (fd < 0) 
    panic("Failed to open %s", elf_file);
  struct stat sb;
  if (fstat(fd, &sb) < 0) 
    panic("Failed to fstat %s", elf_file);
  void *file = mmap(NULL, sb.st_size, PROT_READ, MAP_PRIVATE, fd, 0);
  if (file == MAP_FAILED) panic("Failed to mmap %s", elf_file);
  Elf32_Ehdr *header = file;
  if (memcmp(header->e_ident, ELFMAG, SELFMAG) != 0) 
    panic("%s is not an ELF file", elf_file);
  Elf32_Shdr *sections = file + header->e_shoff;

  int func_cnt = 0;
  for(int i=0; i<header->e_shnum; i++) {
    if (sections[i].sh_type==SHT_SYMTAB) {
      Elf32_Sym *symtab = (Elf32_Sym *)(file + sections[i].sh_offset);
      int num_sym = sections[i].sh_size / sections[i].sh_entsize;
      Elf32_Shdr *strtab = &sections[sections[i].sh_link];
      const char *const strtab_p = (const char *)header + strtab->sh_offset;

      Log("Symbol table '%s' contains %d entries:", strtab_p + sections[i].sh_name, num_sym);
      for (int j = 0; j < num_sym; j++) {
        Elf32_Sym sym = symtab[j];
        if (ELF32_ST_TYPE(sym.st_info)==STT_FUNC) {
          Log("%d: %x, %x, %s", j, sym.st_value, sym.st_size, strtab_p + sym.st_name);
          func_cnt++;
        }
      }
    }
  }
  Log("Total %d functions", func_cnt);

  symbol_funcs = (SymbolFunc *)malloc(sizeof(SymbolFunc) * func_cnt);
  symbol_func_num = 0;
  for(int i=0; i<header->e_shnum; i++) {
    if (sections[i].sh_type==SHT_SYMTAB) {
      Elf32_Sym *symtab = (Elf32_Sym *)(file + sections[i].sh_offset);
      int num_sym = sections[i].sh_size / sections[i].sh_entsize;
      Elf32_Shdr *strtab = &sections[sections[i].sh_link];
      const char *const strtab_p = (const char *)header + strtab->sh_offset;

      Log("Symbol table '%s' contains %d entries:", strtab_p + sections[i].sh_name, num_sym);
      for (int j = 0; j < num_sym; j++) {
        Elf32_Sym sym = symtab[j];
        if (ELF32_ST_TYPE(sym.st_info)==STT_FUNC) {
          symbol_funcs[symbol_func_num].name = strdup(strtab_p + sym.st_name);
          symbol_funcs[symbol_func_num].start_addr = sym.st_value;
          symbol_funcs[symbol_func_num].end_addr = sym.st_value + sym.st_size;
          Log("%s : %x, %x", symbol_funcs[symbol_func_num].name, symbol_funcs[symbol_func_num].start_addr, symbol_funcs[symbol_func_num].end_addr);
          symbol_func_num++;
        }
      }
    }
  }
}

void ftrace_close() {
  if (symbol_func_num==0) return;
  Log("Freeing symbol functions");
  for(int i=0; i<symbol_func_num; i++) {
    free(symbol_funcs[i].name);
  }
  free(symbol_funcs);
}

void ftrace_exec(uint32_t pc_before, uint32_t pc_after, int rd, bool is_jal) {
  if (pc_before==0x8000023c) {
    Log("pc_before = %x, pc_after = %x, rd = %d, is_jal = %d", pc_before, pc_after, rd, is_jal);
  }
  static int stack_depth = 0;
  if (symbol_func_num==0) return;
  int func_before=-1;
  for(int i=0; i<symbol_func_num; i++) {
    if (pc_before>=symbol_funcs[i].start_addr && pc_before<symbol_funcs[i].end_addr) {
      func_before=i;
      break;
    }
  }
  int func_after=-1;
  bool is_call=false;
  for(int i=0; i<symbol_func_num; i++) {
    if (pc_after>=symbol_funcs[i].start_addr && pc_after<symbol_funcs[i].end_addr) {
      func_after=i;
      is_call = (pc_after==symbol_funcs[i].start_addr);
      break;
    }
  }
  if (func_before==-1 || func_after==-1) {
    return;
  }
  if (func_before==func_after) {
    if (rd==1) {
      _Log("%x: %*sFunc Call: %s to %s\n", pc_before, stack_depth,"",symbol_funcs[func_before].name, symbol_funcs[func_after].name);
      stack_depth++;
    } else if (rd==0 && !is_jal) {
      if (stack_depth>0) stack_depth--;
      _Log("%x: %*sFunc Ret: %s to [%s@%x]\n", pc_before, stack_depth, "", symbol_funcs[func_before].name, symbol_funcs[func_after].name, pc_after);
    }
  } else {
    if (is_call) {
      _Log("%x: %*sFunc Call: %s to %s\n", pc_before, stack_depth,"",symbol_funcs[func_before].name, symbol_funcs[func_after].name);
      stack_depth++;
    } else {
      if (stack_depth>0) stack_depth--;
      _Log("%x: %*sFunc Ret: %s to [%s@%x]\n", pc_before, stack_depth, "", symbol_funcs[func_before].name, symbol_funcs[func_after].name, pc_after);
    }
  }
}

void device_update();

static void trace_and_difftest(Decode *_this, vaddr_t dnpc) {
#ifdef CONFIG_ITRACE_COND
  if (ITRACE_COND) { 
    //log_write("%s\n", _this->logbuf); 
    memcpy(instruction_ring_buffer[instruction_ring_buffer_tail], _this->logbuf, sizeof(_this->logbuf));
    int tail = instruction_ring_buffer_tail+1;
    if (tail == INSTRUCTION_LOG_BUF_SIZE) tail = 0;
    if (tail == instruction_ring_buffer_head) {
      instruction_ring_buffer_head ++;
      if (instruction_ring_buffer_head == INSTRUCTION_LOG_BUF_SIZE) instruction_ring_buffer_head = 0;
    }
    instruction_ring_buffer_tail = tail;
  }
#endif
  if (g_print_step) { IFDEF(CONFIG_ITRACE, puts(_this->logbuf)); }
  IFDEF(CONFIG_DIFFTEST, difftest_step(_this->pc, dnpc));
#ifdef CONFIG_WATCHPOINT
  WP* now = get_wp_list();
  while(now!=NULL) {
    bool success = false;
    word_t val = expr(now->expr, &success);
    if(!success) {
      printf("Warning: watchpoint %d expr evaluation failed: %s \n", now->NO, now->expr);
      now=now->next;
      continue;
    }
    if (now->last_value!=val) {
      printf("Watchpoint %d: %s\n", now->NO, now->expr);
      printf("Old value = " FMT_WORD "\n", now->last_value);
      printf("New value = " FMT_WORD "\n", val);
      now->last_value = val;
      nemu_state.state = NEMU_STOP;
      break;
    }
    now=now->next;
  }
#endif
}

static void exec_once(Decode *s, vaddr_t pc) {
  s->pc = pc;
  s->snpc = pc;
  isa_exec_once(s);
  cpu.pc = s->dnpc;
#ifdef CONFIG_ITRACE
  char *p = s->logbuf;
  p += snprintf(p, sizeof(s->logbuf), FMT_WORD ":", s->pc);
  int ilen = s->snpc - s->pc;
  int i;
  uint8_t *inst = (uint8_t *)&s->isa.inst.val;
  for (i = ilen - 1; i >= 0; i --) {
    p += snprintf(p, 4, " %02x", inst[i]);
  }
  int ilen_max = MUXDEF(CONFIG_ISA_x86, 8, 4);
  int space_len = ilen_max - ilen;
  if (space_len < 0) space_len = 0;
  space_len = space_len * 3 + 1;
  memset(p, ' ', space_len);
  p += space_len;

#ifndef CONFIG_ISA_loongarch32r
  void disassemble(char *str, int size, uint64_t pc, uint8_t *code, int nbyte);
  disassemble(p, s->logbuf + sizeof(s->logbuf) - p,
      MUXDEF(CONFIG_ISA_x86, s->snpc, s->pc), (uint8_t *)&s->isa.inst.val, ilen);
#else
  p[0] = '\0'; // the upstream llvm does not support loongarch32r
#endif
#endif
}

static void execute(uint64_t n) {
  Decode s;
  for (;n > 0; n --) {
    exec_once(&s, cpu.pc);
    g_nr_guest_inst ++;
    trace_and_difftest(&s, cpu.pc);
    if (nemu_state.state != NEMU_RUNNING) break;
    IFDEF(CONFIG_DEVICE, device_update());
  }
}

static void statistic() {
  IFNDEF(CONFIG_TARGET_AM, setlocale(LC_NUMERIC, ""));
#define NUMBERIC_FMT MUXDEF(CONFIG_TARGET_AM, "%", "%'") PRIu64
  Log("host time spent = " NUMBERIC_FMT " us", g_timer);
  Log("total guest instructions = " NUMBERIC_FMT, g_nr_guest_inst);
  if (g_timer > 0) Log("simulation frequency = " NUMBERIC_FMT " inst/s", g_nr_guest_inst * 1000000 / g_timer);
  else Log("Finish running in less than 1 us and can not calculate the simulation frequency");
}

void assert_fail_msg() {
  isa_reg_display();
  statistic();
}

/* Simulate how the CPU works. */
void cpu_exec(uint64_t n) {
  g_print_step = (n < MAX_INST_TO_PRINT);
  switch (nemu_state.state) {
    case NEMU_END: case NEMU_ABORT:
      printf("Program execution has ended. To restart the program, exit NEMU and run again.\n");
      return;
    default: nemu_state.state = NEMU_RUNNING;
  }

  uint64_t timer_start = get_time();

  execute(n);

  uint64_t timer_end = get_time();
  g_timer += timer_end - timer_start;

  switch (nemu_state.state) {
    case NEMU_RUNNING: nemu_state.state = NEMU_STOP; break;

    case NEMU_END: case NEMU_ABORT:
      Log("nemu: %s at pc = " FMT_WORD,
          (nemu_state.state == NEMU_ABORT ? ANSI_FMT("ABORT", ANSI_FG_RED) :
           (nemu_state.halt_ret == 0 ? ANSI_FMT("HIT GOOD TRAP", ANSI_FG_GREEN) :
            ANSI_FMT("HIT BAD TRAP", ANSI_FG_RED))),
          nemu_state.halt_pc);
      // fall through
    case NEMU_QUIT: statistic();
  }
}
