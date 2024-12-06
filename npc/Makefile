YSYXSOC_FILES := $(shell find ../ysyxSoC/perip -type f -name "*.v")

.PHONY: sim clean
all:

run: sim
	./obj_dir/VysyxSoCFull +trace $(BATCH_MODE) $(IMG) $(ELF) $(DIFFTEST_REF)
gdb: sim
	gdb --args ./obj_dir/VysyxSoCFull -trace $(BATCH_MODE) $(IMG) $(ELF) $(DIFFTEST_REF)

sim:
	$(call git_commit, "sim RTL") # DO NOT REMOVE THIS LINE!!!
	verilator -cc --exe --build -x-assign fast --trace --assert --coverage -CFLAGS -ggdb  -LDFLAGS -ggdb -j 8 \
	--timescale "1ns/1ns" --no-timing --top-module ysyxSoCFull --autoflush \
	-I../ysyxSoC/perip/uart16550/rtl -I../ysyxSoC/perip/spi/rtl \
	csrc/main.cpp csrc/dpi.cpp csrc/sdb/sdb.cpp csrc/sdb/watchpoint.cpp csrc/sdb/expr.cpp \
	csrc/isa/isa.cpp csrc/common.cpp csrc/utils/disasm.cpp \
	csrc/difftest/dut.cpp \
	/usr/lib/libreadline.so /usr/lib/libLLVM-18.so \
	vsrc/TopLevel.v vsrc/EBreak.v vsrc/PMem.v vsrc/UART_V.v vsrc/DiffTestSignal.v \
	$(YSYXSOC_FILES) ../ysyxSoC/build/ysyxSoCFull.v
clean:
	rm -rf obj_dir logs

include ../Makefile
