#include "dpi.h"
#include "isa/isa.h"
#include "sdb/sdb.h"
extern "C" {
	bool is_ebreak;
	uint8_t ebreak_code;
	void ebreak(uint8_t code)
	{
		is_ebreak=true;
		ebreak_code=code;
	}
	int pmem_read(int raddr) {
		word_t data= paddr_read(raddr, 4);
		//Log("pmem_read: raddr=0x%x, data=0x%x\n", raddr, data);
		if (*imem_en_ref) {
			trace_exec(raddr, data);
		}
		return data;
	}
	void pmem_write(int waddr, int wdata, char wmask) {
		int len=0;
		if (wmask==0b1) {
			len=1;
		} else if (wmask==0b11) {
			len=2;
		} else if (wmask==0b1111){
			len=4;
		} else {
			return;
		}
		paddr_write(waddr, len, wdata);
	}
}
