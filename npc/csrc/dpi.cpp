#include "dpi.h"
#include "common.h"
#include "isa/isa.h"
#include "sdb/sdb.h"
#include <cstdint>
#include "difftest/difftest-def.h"
static uint64_t time_tmp=0;
extern "C" {
	bool is_ebreak;
	uint8_t ebreak_code;
	void ebreak(uint8_t code)
	{
		is_ebreak=true;
		ebreak_code=code;
	}
	int pmem_read(int raddr) {
		word_t ret=0;
		bool mmio=false;
		assert(raddr!=RTC_ADDR);
		if (raddr == RTC_ADDR) {
			printf("%x\n",(unsigned)raddr);
			mmio=true;
			ret = (uint32_t) time_tmp;
			#ifdef CONFIG_DTRACE
			dtrace_read("RTC", raddr, ret);
			#endif
		} else if (raddr==RTC_ADDR+4) {
			mmio=true;
			time_tmp = get_time();
			ret= time_tmp >> 32;
			#ifdef CONFIG_DTRACE
			dtrace_read("RTC", raddr, ret);
			#endif
		}
		if (mmio) {
			#ifdef CONFIG_DIFFTEST
			difftest_skip_ref();
			#endif
			return ret;
		}
		raddr = raddr & ~0x3u;
		word_t data= paddr_read(raddr, 4);
		//Log("pmem_read: raddr=0x%x, data=0x%x\n", raddr, data);
#ifdef CONFIG_TRACE
		if (*imem_en_ref) {
			trace_exec(raddr, data);
		}
#endif
		return data;
	}
	void pmem_write(int waddr, int wdata, char wmask) {
		bool mmio=false;
		assert(waddr!=SERIAL_PORT);
		if (waddr == SERIAL_PORT) {
			#ifdef CONFIG_DTRACE
			dtrace_write("serial", waddr, wdata);
			#endif
			//putchar(wdata);
			fflush(stdout);
			mmio=true;
			//fflush(stdout);
			//return;
		}
		if (mmio) {
			#ifdef CONFIG_DIFFTEST
			difftest_skip_ref();
			#endif
			return;
		}
		paddr_write(waddr,wmask, wdata);
	}
}
