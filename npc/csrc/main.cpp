#include <stdio.h>
#include <stdlib.h>
#include <assert.h>
#include <stdbool.h>
#include "Vtop.h"
#include <verilated.h>

int main(int argc, char** argv) {
	Verilated::mkdir("logs");
	const std::unique_ptr<VerilatedContext> contextp{new VerilatedContext};
	contextp->debug(0);
	contextp->randReset(2);
	contextp->traceEverOn(true);
    contextp->commandArgs(argc, argv);
	const std::unique_ptr<Vtop> top{new Vtop{contextp.get(), "TOP"}};
	for(int i=0; i<128; i++) {
		contextp->timeInc(1);
	  int a = rand() & 1;
	  int b = rand() & 1;
	  top->a = a;
	  top->b = b;
	  top->eval();
	  printf("a = %d, b = %d, f = %d\n", a, b, top->f);
	  assert(top->f == (a ^ b));
	}
	top->final();
	contextp->coveragep()->write("logs/coverage.dat");
}
