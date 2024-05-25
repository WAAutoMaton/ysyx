#include <cstdint>
extern "C" {
	extern bool is_ebreak;
	extern uint8_t ebreak_code;
	void ebreak(uint8_t);
	int pmem_read(int raddr);
	void pmem_write(int waddr, int wdata, char wmask);
}
