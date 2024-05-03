#include <stdio.h>
#include <stdlib.h>
#include <assert.h>
#include <stdbool.h>
#include "VTopLevel.h"
#include <verilated.h>
#include "dpi.h"

constexpr int MEM_SIZE=1024*1024;

//uint32_t mem[MEM_SIZE]={0x3e800093U,0x7d008113U,0xc1810193U,0x83018213U,0x3e820293U,0x00100073U};
uint32_t mem[MEM_SIZE];

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
	const std::unique_ptr<VerilatedContext> contextp{new VerilatedContext};
	contextp->debug(0);
	contextp->randReset(2);
	contextp->traceEverOn(true);
    contextp->commandArgs(argc, argv);
	const std::unique_ptr<VTopLevel> top{new VTopLevel{contextp.get(), "TOP"}};
	top->reset=1;
	top->clock=0;
	top->eval();
	top->clock=1;
	top->eval();
	top->reset=0;
	bool good_exit=false;
	for(int i=0; i<512; i++) {
	  contextp->timeInc(1);
	  top->clock=0;
	  top->eval();
	  top->clock=1;
	  top->eval();
	  if (is_ebreak) {
		  good_exit=true;
		  printf("At %d cycle, ebreak called. Exited.\n",i);
		  break;
	  }
	  if (top->io_mem_read_en) {
		  printf("Read %x\n", top->io_mem_read_address);
		  top->io_mem_read_value = mem[(top->io_mem_read_address-0x80000000L)/4];
	  }
	  if (i%3==0) {
	  printf("After %d cycle:\n",i);
	  printf("Reg 1: %x\n",top->io_test_regs_1);
	  printf("Reg 2: %x\n",top->io_test_regs_2);
	  printf("Reg 3: %x\n",top->io_test_regs_3);
	  printf("Reg 4: %x\n",top->io_test_regs_4);
	  printf("Reg 5: %x\n",top->io_test_regs_5);
	  }
	}
	top->final();
	contextp->coveragep()->write("logs/coverage.dat");
	if (!good_exit) {
		puts("Program exited abnormally.");
		return 1;
	}
}
