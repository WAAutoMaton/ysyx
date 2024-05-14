#pragma once

#include <stdint.h>

// calculate the length of an array
#define ARRLEN(arr) (int)(sizeof(arr) / sizeof(arr[0]))

typedef uint32_t word_t;
typedef uint32_t paddr_t;