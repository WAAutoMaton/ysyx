#include "common.h"
#include <cstdlib>

FILE* log_fp;

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