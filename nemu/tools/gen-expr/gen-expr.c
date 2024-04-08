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

#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <assert.h>
#include <string.h>

// this should be enough
static char buf[65536] = {};
static char *buf_tail;
static char code_buf[65536 + 128] = {}; // a little larger than `buf`
static char *code_format =
"#include <stdio.h>\n"
"int main() { "
"  unsigned result = %s; "
"  printf(\"%%u\", result); "
"  return 0; "
"}";

static int choose(int n) {
  return rand()%n;
}

static void insert_space() {
    if (choose(4)==0) {
      *buf_tail++=' ';
    }
}
static void gen_rand_expr() {
  int x = choose(3);
  if (buf_tail-buf > 10000) {
    x=0;
  }
  if (x==0) {
    int num=rand();
    sprintf(buf_tail, "%d", num);
    while(*buf_tail != '\0') buf_tail++;
    *buf_tail++ = 'U';
  } else if (x==1) {
    insert_space();
    *buf_tail++ = '(';
    insert_space();
    gen_rand_expr();
    insert_space();
    *buf_tail++ = ')';
    insert_space();
  } else {
    insert_space();
    gen_rand_expr();
    insert_space();
    int op = choose(4);
    switch(op) {
      case 0: *buf_tail++ = '+'; break;
      case 1: *buf_tail++ = '-'; break;
      case 2: *buf_tail++ = '*'; break;
      case 3: *buf_tail++ = '/'; break;
    }
    insert_space();
    gen_rand_expr();
    insert_space();
  }
}

int main(int argc, char *argv[]) {
  int seed = time(0);
  srand(seed);
  int loop = 1;
  if (argc > 1) {
    sscanf(argv[1], "%d", &loop);
  }
  int i;
  for (i = 0; i < loop; i ++) {
    buf_tail = buf;
    gen_rand_expr();
    *buf_tail='\0';

    sprintf(code_buf, code_format, buf);

    FILE *fp = fopen("/tmp/.code.c", "w");
    assert(fp != NULL);
    fputs(code_buf, fp);
    fclose(fp);

    int ret = system("gcc -Wall -Werror -O2 /tmp/.code.c -o /tmp/.expr");
    if (ret != 0) continue;

    fp = popen("/tmp/.expr", "r");
    assert(fp != NULL);

    int result;
    ret = fscanf(fp, "%d", &result);
    pclose(fp);

    printf("%u %s\n", result, buf);
  }
  return 0;
}
