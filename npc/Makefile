.PHONY: sim clean
all:

run: sim
	./obj_dir/VTopLevel +trace $(IMG)

sim:
	$(call git_commit, "sim RTL") # DO NOT REMOVE THIS LINE!!!
	verilator -cc --exe --build -x-assign fast --trace --assert --coverage csrc/main.cpp csrc/dpi.cpp vsrc/TopLevel.v vsrc/EBreak.v
clean:
	rm -rf obj_dir logs

include ../Makefile
