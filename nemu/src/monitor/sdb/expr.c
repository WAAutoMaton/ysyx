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

#include "common.h"
#include <isa.h>

/* We use the POSIX regex functions to process regular expressions.
 * Type 'man regex' for more information about POSIX regex functions.
 */
#include <regex.h>

enum {
  TK_NOTYPE = 256, TK_EQ, TK_ADD, TK_SUB, TK_MUL, TK_DIV,
  TK_LEFT_PAREN, TK_RIGHT_PAREN, TK_INTEGER,

};

static struct rule {
  const char *regex;
  int token_type;
} rules[] = {

  /* TODO: Add more rules.
   * Pay attention to the precedence level of different rules.
   */

  {" +", TK_NOTYPE},    // spaces
  {"\\+",TK_ADD},         // plus
  {"\\-",TK_SUB},
  {"\\*",TK_MUL},
  {"\\/",TK_DIV},
  {"\\(",TK_LEFT_PAREN},
  {"\\)",TK_RIGHT_PAREN},
      {"[0-9]+",TK_INTEGER}, // integer
  {"==", TK_EQ},        // equal
};

#define NR_REGEX ARRLEN(rules)

static regex_t re[NR_REGEX] = {};

/* Rules are used for many times.
 * Therefore we compile them only once before any usage.
 */
void init_regex() {
  int i;
  char error_msg[128];
  int ret;

  for (i = 0; i < NR_REGEX; i ++) {
    ret = regcomp(&re[i], rules[i].regex, REG_EXTENDED);
    if (ret != 0) {
      regerror(ret, &re[i], error_msg, 128);
      panic("regex compilation failed: %s\n%s", error_msg, rules[i].regex);
    }
  }
}

typedef struct token {
  int type;
  char str[32];
} Token;

static Token tokens[32] __attribute__((used)) = {};
static int nr_token __attribute__((used))  = 0;

static bool make_token(char *e) {
  int position = 0;
  int i;
  regmatch_t pmatch;

  nr_token = 0;

  while (e[position] != '\0') {
    /* Try all rules one by one. */
    for (i = 0; i < NR_REGEX; i ++) {
      if (regexec(&re[i], e + position, 1, &pmatch, 0) == 0 && pmatch.rm_so == 0) {
        char *substr_start = e + position;
        int substr_len = pmatch.rm_eo;

        Log("match rules[%d] = \"%s\" at position %d with len %d: %.*s",
            i, rules[i].regex, position, substr_len, substr_len, substr_start);

        position += substr_len;

        /* TODO: Now a new token is recognized with rules[i]. Add codes
         * to record the token in the array `tokens'. For certain types
         * of tokens, some extra actions should be performed.
         */
        tokens[nr_token].type = rules[i].token_type;
        if (substr_len>31) {
          puts("Token too long!");
          return false;
        }
        strncpy(tokens[nr_token].str, substr_start, substr_len);

        nr_token++;

        break;
      }
    }

    if (i == NR_REGEX) {
      printf("no match at position %d\n%s\n%*.s^\n", position, e, position, "");
      return false;
    }
  }

  return true;
}

static int eval_error;
static bool check_parentheses(int p,int q)
{
  if (p-q<=2) return false;
  if (!(tokens[p].type==TK_LEFT_PAREN && tokens[q].type==TK_RIGHT_PAREN)) return false;
  int cnt=0;
  for(int i=p+1;i<q;i++) {
    if (tokens[i].type==TK_LEFT_PAREN) cnt++;
    if (tokens[i].type==TK_RIGHT_PAREN) cnt--;
    if (cnt<0) {
      eval_error = -3;
      return false;
    }
  }
  return cnt==0;
}

static sword_t eval(int p, int q)
{
  if (p>q) {
    eval_error = -2;
    return 0;
  } else if (p==q) {
    if(tokens[p].type==TK_INTEGER) {
      return atoi(tokens[p].str);
    } else {
      eval_error = -1;
      return 0;
    }
  } else if (check_parentheses(p,q)) {
    return eval(p+1,q-1);
  } else {
    if (eval_error<0) return 0; 
    int op=-1;
    int paren_cnt=0;
    for(int i=p; i<=q; i++) {
      if (tokens[i].type==TK_LEFT_PAREN) paren_cnt++;
      else if (tokens[i].type==TK_RIGHT_PAREN) paren_cnt--;
      else if (paren_cnt==0) {
        if (tokens[i].type==TK_ADD || tokens[i].type==TK_SUB) {
          op=i;
        } else if (tokens[i].type==TK_MUL || tokens[i].type==TK_DIV) {
          if (op==-1 || tokens[i].type==TK_MUL || tokens[i].type==TK_DIV) op=i;
        }
      }
    }
    if (op==-1) {
      eval_error = -4;
      return 0;
    }
    sword_t val1=eval(p,op-1);
    sword_t val2=eval(op+1,q);
    switch(tokens[op].type) {
      case TK_ADD: return val1+val2;
      case TK_SUB: return val1-val2;
      case TK_MUL: return val1*val2;
      case TK_DIV:
        if (val2==0) {
          eval_error = -5;
          return 0;
        }
      default: assert(0);
    }
  }
}

sword_t expr(char *e, bool *success) {
  if (!make_token(e)) {
    *success = false;
    return 0;
  }

  eval_error = 0;
  sword_t result = eval(0,nr_token-1);
  if (eval_error<0) {
    *success = false;
    return 0;
  }
  return result;
}
