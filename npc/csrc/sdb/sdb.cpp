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

#include <stddef.h>
#include <assert.h>
#include <cstdio>
#include <cstdlib>
#include <fcntl.h>
#include <elf.h>
#include <unistd.h>
#include <readline/readline.h>
#include <readline/history.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <sys/mman.h>
#include "sdb.h"
#include "../common.h"
#include "watchpoint.h"
#include "../isa/isa.h"
#include "../utils/disasm.h"

static int is_batch_mode = false;

void init_regex();
void init_wp_pool();

/* We use the `readline' library to provide more flexibility to read from stdin. */
static char* rl_gets() {
  static char *line_read = NULL;

  if (line_read) {
    free(line_read);
    line_read = NULL;
  }

  line_read = readline("(npc) ");

  if (line_read && *line_read) {
    add_history(line_read);
  }

  return line_read;
}

static int cmd_c(char *args) {
  cpu_exec(-1);
  return 0;
}


static int cmd_q(char *args) {
  npc_status=NPC_STATUS_QUIT;
  return -1;
}

static int cmd_si(char *args) {
    int n=0;
    if (args!=NULL) {
        n=atoi(args);
    }
    if (n<=0) n=1;
    printf("Execute %d steps\n", n);
    cpu_exec(n);
    return 0;
}


static int cmd_info(char *args) {
    static const char info_help[] = "Format: info <r|w>";
    if (args==NULL) {
        puts(info_help);
        return 0;
    }
    char *p=strtok(args, " ");
    if (p==NULL || strlen(p)!=1) {
        puts(info_help);
        return 0;
    }
    if (*p=='r') {
      isa_reg_display();
    } else if (*p=='w') {
      WP* now = get_wp_list();
      while(now!=NULL) {
        printf("ID: %d, EXPR: %s\n",now->NO,now->expr);
        now=now->next;
      }
    } else {
        puts(info_help);
    }
    return 0;
}

static int cmd_x(char *args) {
    const char *x_help = "Format: x N EXPR";
    if (args==NULL) {
        puts(x_help);
        return 0;
    }
    char *p_N=strtok(args, " ");
    if (p_N==NULL) {
        puts(x_help);
        return 0;
    }
    int N=atoi(p_N);
    if (N<=0) {
        puts(x_help);
        return 0;
    }
    char *p_EXPR=strtok(NULL, " ");
    if (p_EXPR==NULL) {
        puts(x_help);
        return 0;
    }
    long long addr=atoll(p_EXPR);
    if (addr<=0) {
        puts(x_help);
        return 0;
    }
    for(int i=0; i<N; i++) {
        printf("0x%08llx: ", addr);
        for(int j=0; j<4; j++) {
            printf("%02x ", vaddr_read(addr, 1));
            addr++;
        }
        printf("\n");
    }
    return 0;
}

static int cmd_d(char *args)
{
  if (args==NULL) {
    puts("Format: d <ID>");
    return 0;
  }
  int id=atoi(args);
  if (id<=0 || id>NR_WP) {
    puts("Format: d <ID>");
    return 0;
  }
  WP* now = get_wp_list();
  if (now->NO==id) {
    free_wp(now,NULL);
    return 0;
  }
  while(now!=NULL) {
    WP* nxt = now->next;
    if (nxt!=NULL && nxt->NO==id) {
      free_wp(nxt,now);
      return 0;
    }
  }
  puts("WatchPoint not exists!");
  return 0;
}
static int cmd_p(char *args)
{
  if (args==NULL) {
    puts("Format: p EXPR");
    return 0;
  }
  bool success=true;
  word_t result=expr(args, &success);
  if (success) {
    printf("%llu\n", (unsigned long long)result);
  } else {
    puts("Invalid expression");
  }
  return 0; 
}
static int cmd_w(char *args)
{
  if (args==NULL) {
    puts("Format: w <EXPR>");
    return 0;
  }
  if (strlen(args)>=WP_MAX_EXPR) {
    puts("expr too long!");
    return 0;
  }
  bool success=true;
  word_t result=expr(args, &success);
  if (!success) {
    puts("Invalid expression");
    return 0;
  }
  WP* wp = new_wp();
  wp->last_value=result;
  strcpy(wp->expr,args);
  printf("ID: %d\n",wp->NO);
  return 0;
}


static int cmd_help(char *args);

static struct {
  const char *name;
  const char *description;
  int (*handler) (char *);
} cmd_table [] = {
  { "help", "Display information about all supported commands", cmd_help },
  { "c", "Continue the execution of the program", cmd_c },
  { "q", "Exit NEMU", cmd_q },
  { "si", "Execute N steps", cmd_si},
  { "info", "Show registers or watchpoint", cmd_info},
  { "x", "Scan memory", cmd_x},
  { "p", "Print expression", cmd_p},
  { "w", "Set watchpoint", cmd_w},
  { "d", "Delete watchpoint", cmd_d},

};

#define NR_CMD ARRLEN(cmd_table)

static int cmd_help(char *args) {
  /* extract the first argument */
  char *arg = strtok(NULL, " ");
  int i;

  if (arg == NULL) {
    /* no argument given */
    for (i = 0; i < NR_CMD; i ++) {
      printf("%s - %s\n", cmd_table[i].name, cmd_table[i].description);
    }
  }
  else {
    for (i = 0; i < NR_CMD; i ++) {
      if (strcmp(arg, cmd_table[i].name) == 0) {
        printf("%s - %s\n", cmd_table[i].name, cmd_table[i].description);
        return 0;
      }
    }
    printf("Unknown command '%s'\n", arg);
  }
  return 0;
}

void sdb_set_batch_mode() {
  is_batch_mode = true;
}

void sdb_mainloop() {
  if (is_batch_mode) {
    cmd_c(NULL);
    return;
  }

  for (char *str; (str = rl_gets()) != NULL; ) {
    char *str_end = str + strlen(str);

    /* extract the first token as the command */
    char *cmd = strtok(str, " ");
    if (cmd == NULL) { continue; }

    /* treat the remaining string as the arguments,
     * which may need further parsing
     */
    char *args = cmd + strlen(cmd) + 1;
    if (args >= str_end) {
      args = NULL;
    }

#ifdef CONFIG_DEVICE
    extern void sdl_clear_event_queue();
    sdl_clear_event_queue();
#endif

    int i;
    for (i = 0; i < NR_CMD; i ++) {
      if (strcmp(cmd, cmd_table[i].name) == 0) {
        if (cmd_table[i].handler(args) < 0) { return; }
        break;
      }
    }

    if (i == NR_CMD) { printf("Unknown command '%s'\n", cmd); }
  }
}

void init_sdb(const char* elf_file) {
  /* Compile the regular expressions. */
  init_regex();

  /* Initialize the watchpoint pool. */
  init_wp_pool();

  instruction_ring_buffer_init();

  init_disasm("riscv32");

  ftrace_init(elf_file);
}

char instruction_ring_buffer[INSTRUCTION_LOG_BUF_SIZE][128];
int instruction_ring_buffer_head, instruction_ring_buffer_tail;
void instruction_ring_buffer_init() {
  instruction_ring_buffer_head = 0;
  instruction_ring_buffer_tail = 0;
}
void instruction_ring_buffer_write() {
  for (int i = instruction_ring_buffer_head; i != instruction_ring_buffer_tail; (i==INSTRUCTION_LOG_BUF_SIZE-1)?i=0:i++) {
    log_write("%s\n", instruction_ring_buffer[i]);
  }
}
void instruction_ring_buffer_push(word_t code, word_t pc)
{
  char disasm_buf[96];
  uint8_t code_buf[4];
  for(int i = 0; i < 4; i++) {
    code_buf[i] = (code >> (i * 8)) & 0xff;
  }
  disassemble(disasm_buf, 96, pc, code_buf, 4);
  char log_buf[128];
  sprintf(log_buf, "0x%08x: %02x %02x %02x %02x\t%s", pc, code_buf[0], code_buf[1], code_buf[2], code_buf[3], disasm_buf);
  memcpy(instruction_ring_buffer[instruction_ring_buffer_tail], log_buf, sizeof(log_buf));
  int tail = instruction_ring_buffer_tail+1;
  if (tail == INSTRUCTION_LOG_BUF_SIZE) tail = 0;
  if (tail == instruction_ring_buffer_head) {
    instruction_ring_buffer_head ++;
    if (instruction_ring_buffer_head == INSTRUCTION_LOG_BUF_SIZE) instruction_ring_buffer_head = 0;
  }
  instruction_ring_buffer_tail = tail;
}

SymbolFunc *symbol_funcs;
int symbol_func_num;

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
  Elf32_Ehdr *header = (Elf32_Ehdr*)file;
  if (memcmp(header->e_ident, ELFMAG, SELFMAG) != 0) 
    panic("%s is not an ELF file", elf_file);
  Elf32_Shdr *sections = (Elf32_Shdr*)((uint8_t*)file + header->e_shoff);

  int func_cnt = 0;
  for(int i=0; i<header->e_shnum; i++) {
    if (sections[i].sh_type==SHT_SYMTAB) {
      Elf32_Sym *symtab = (Elf32_Sym *)((uint8_t*)file + sections[i].sh_offset);
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
      Elf32_Sym *symtab = (Elf32_Sym *)((uint8_t*)file + sections[i].sh_offset);
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

void assert_fail_msg() {
  isa_reg_display();
  //statistic();
}