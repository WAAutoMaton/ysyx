#include "common.h"
#include <cstdlib>
#include <time.h>

FILE* log_fp;
int npc_status;

bool log_enable(){
    return true;
}

void log_init() {
    log_fp = fopen("logs/log.txt", "w");
    if (log_fp==NULL) {
        printf("Failed to open log file\n");
        exit(1);
    }
}

void log_close() {
    fclose(log_fp);
}
uint64_t get_time_internal() {
  struct timespec now;
  clock_gettime(CLOCK_MONOTONIC_COARSE, &now);
  uint64_t us = now.tv_sec * 1000000 + now.tv_nsec / 1000;
  return us;
}
uint64_t get_time() {
	static uint64_t boot_time=0;
	if (boot_time==0) boot_time = get_time_internal();
	return get_time_internal() - boot_time;
}