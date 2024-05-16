.PHONY: sim clean
all:

run: sim
	./obj_dir/VTopLevel +trace $(IMG) $(ELF) $(DIFFTEST_REF)
gdb: sim
	gdb --args ./obj_dir/VTopLevel +trace $(IMG) $(ELF) $(DIFFTEST_REF)

sim:
	$(call git_commit, "sim RTL") # DO NOT REMOVE THIS LINE!!!
	verilator -cc --exe --build -x-assign fast --trace --assert --coverage -CFLAGS -ggdb  -LDFLAGS -ggdb \
	csrc/main.cpp csrc/dpi.cpp csrc/sdb/sdb.cpp csrc/sdb/watchpoint.cpp csrc/sdb/expr.cpp \
	csrc/isa/isa.cpp csrc/common.cpp csrc/utils/disasm.cpp \
	csrc/difftest/dut.cpp \
	/usr/lib/libreadline.so /usr/lib/libLLVM-17.so \
	vsrc/TopLevel.v vsrc/EBreak.v
clean:
	rm -rf obj_dir logs

include ../Makefile
