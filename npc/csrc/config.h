#pragma once

#define CONFIG_MBASE 0x80000000L
#define CONFIG_TRACE 
#ifdef CONFIG_TRACE
#   define CONFIG_DIFFTEST
//#   define CONFIG_MTRACE
//#   define CONFIG_FTRACE
//#   define CONFIG_ITRACE
#   define CONFIG_DTRACE
#endif