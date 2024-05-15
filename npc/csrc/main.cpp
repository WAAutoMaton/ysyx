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
int last_pc=0;
int ftrace_inst;
int ftrace_rd;
int ftrace_pc;

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
	  if (ftrace_inst!=0 && top->io_mem_read_address!=ftrace_pc) {
		ftrace_exec(ftrace_pc, top->io_mem_read_address, ftrace_rd, (ftrace_inst&0x7f)==0x6f);
		ftrace_inst=0;
	  }
	  if (top->io_mem_read_en) {
		  printf("Read %x\n", top->io_mem_read_address);
		  top->io_mem_read_value = mem[(top->io_mem_read_address-0x80000000L)/4];
		  uint32_t instr = top->io_mem_read_value;
		  instruction_ring_buffer_push(top->io_mem_read_value, instr);
		  // Is jal/jalr
		  if ((instr & 0x7f) == 0x6f || (instr & 0x7f) == 0x67) {
			ftrace_inst = instr;
			ftrace_rd = (instr >> 7) & 0x1f;
			ftrace_pc = top->io_mem_read_address;
		  }
	  }
	}
}

int main(int argc, char** argv) {
	if (argc<4) {
		puts("Format: <x.exe> +trace <executable image> <elf file>");
		return 0;
	}
	log_init();
	FILE* f=fopen(argv[2],"rb");
	if (f==nullptr) {
		puts("Open executable image failed");
	}
	const char* elf = argv[3];
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
	init_sdb(elf);

	sdb_mainloop();

    instruction_ring_buffer_write();
    ftrace_close();

	top->final();
	contextp->coveragep()->write("logs/coverage.dat");
	if (!npc_good_exit) {
		puts("Program exited abnormally.");
		log_close();
		return 1;
	}

	log_close();
}
