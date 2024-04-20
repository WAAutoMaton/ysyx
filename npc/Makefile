.PHONY: sim clean
all:

run: sim
	./obj_dir/Vtop +trace

sim:
	$(call git_commit, "sim RTL") # DO NOT REMOVE THIS LINE!!!
	verilator -cc --exe --build -x-assign fast -Wall --trace --assert --coverage csrc/main.cpp vsrc/top.v
clean:
	rm -rf obj_dir logs

include ../Makefile
