#include <stdio.h>
#include <stdlib.h>
#include <assert.h>
#include <stdbool.h>
#include "VTopLevel.h"
#include <verilated.h>
#include "dpi.h"
#include "sdb/sdb.h"
#include "isa/isa.h"

bool npc_good_exit;
int cycle_cnt;

void cpu_exec(int n)
{
	if (n<0) {
		n=0x3fffffff;
	}
	for(int i=0; i<n; i++) {
	  cycle_cnt++;
	  contextp->timeInc(1);
	  top->clock=0;
	  top->eval();
	  top->clock=1;
	  top->eval();
	  if (is_ebreak) {
		  npc_good_exit=true;
		  printf("At %d cycle, ebreak called. Exited.\n", cycle_cnt);
		  break;
	  }
	  if (top->io_mem_read_en) {
		  printf("Read %x\n", top->io_mem_read_address);
		  top->io_mem_read_value = mem[(top->io_mem_read_address-0x80000000L)/4];
	  }
	}
}

int main(int argc, char** argv) {
	if (argc<3) {
		puts("Format: <x.exe> +trace <executable file>");
		return 0;
	}
	FILE* f=fopen(argv[2],"rb");
	if (f==NULL) {
		puts("Open executable file failed");
	}
	fread(mem,MEM_SIZE,4,f);
	is_ebreak=false;
	Verilated::mkdir("logs");
	contextp->debug(0);
	contextp->randReset(2);
	contextp->traceEverOn(true);
    contextp->commandArgs(argc, argv);
	top->reset=1;
	top->clock=0;
	top->eval();
	top->clock=1;
	top->eval();
	top->reset=0;
	npc_good_exit=false;

	init_isa();
	init_sdb(NULL);
	sdb_mainloop();

	top->final();
	contextp->coveragep()->write("logs/coverage.dat");
	if (!npc_good_exit) {
		puts("Program exited abnormally.");
		return 1;
	}
}
