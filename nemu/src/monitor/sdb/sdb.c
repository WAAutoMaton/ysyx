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

#include <isa.h>
#include <cpu/cpu.h>
#include <readline/readline.h>
#include <readline/history.h>
#include "sdb.h"
#include <memory/vaddr.h>

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

  line_read = readline("(nemu) ");

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

static int cmd_d(char *args){return 0;}
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
static int cmd_w(char *args){return 0;}


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

  /* TODO: Add more commands */

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

void init_sdb() {
  /* Compile the regular expressions. */
  init_regex();

  /* Initialize the watchpoint pool. */
  init_wp_pool();
}
