#include <cstdint>
extern "C" {
	extern bool is_ebreak;
	extern uint8_t ebreak_code;
	void ebreak(uint8_t);
	int pmem_read(int raddr);
	void pmem_write(int waddr, int wdata, char wmask);
	void difftest_signal_up(
		int pc,
		int regs_0, int regs_1,  int regs_2,  int regs_3,
		int regs_4, int regs_5,  int regs_6,  int regs_7,
		int regs_8, int regs_9,  int regs_10,  int regs_11,
		int regs_12, int regs_13,  int regs_14,  int regs_15,
		int regs_16, int regs_17,  int regs_18,  int regs_19,
		int regs_20, int regs_21,  int regs_22,  int regs_23,
		int regs_24, int regs_25,  int regs_26,  int regs_27,
		int regs_28, int regs_29,  int regs_30,  int regs_31,
		int csr_0,  int csr_1,  int csr_2,  int csr_3, int csr_4, int csr_5
	);
}
