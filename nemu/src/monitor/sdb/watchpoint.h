#pragma once

#include "sdb.h"

#define NR_WP 32
#define WP_MAX_EXPR 256

typedef struct watchpoint {
  int NO;
  struct watchpoint *next;
  char expr[WP_MAX_EXPR];
} WP;
void init_wp_pool();
WP* new_wp();
void free_wp(WP *wp, WP* prev);
WP* get_wp_list();