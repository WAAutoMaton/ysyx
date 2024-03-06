all:

sim:
	$(call git_commit, "sim RTL") # DO NOT REMOVE THIS LINE!!!
	verilator -cc --exe --build -x-assign fast -Wall --trace --assert --coverage csrc/main.cpp vsrc/top.v


include ../Makefile
