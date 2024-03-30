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

#include <common.h>
#include "monitor/sdb/sdb.h"

void init_monitor(int, char *[]);
void am_init_monitor();
void engine_start();
int is_exit_status_bad();

static void test_expr() {
    FILE *input_file = fopen("./input", "r");
    if (input_file == NULL) {
      puts("Input file not found");
        return;
    }
    word_t answer;
    while(fscanf(input_file, "%u", &answer) != EOF) {
        char expr_str[65536];
        fgets(expr_str, 65536, input_file);
        bool ok;
        word_t result = expr(expr_str, &ok);
        if (!ok) {
          printf("Test failed: %s -> FAILED, expect %u\n", expr_str, answer);
        } else if (result != answer) {
            printf("Test failed: %s -> %u, expect %u\n", expr_str, result, answer);
        }
    }
}

int main(int argc, char *argv[]) {
  if (argc == 3 && strcmp(argv[2], "--expr-test")==0) {
    void init_regex();
    init_regex();
    test_expr();
    return 0;
  }
  /* Initialize the monitor. */
#ifdef CONFIG_TARGET_AM
  am_init_monitor();
#else
  init_monitor(argc, argv);
#endif

  /* Start engine. */
  engine_start();

  return is_exit_status_bad();
}
