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
	void difftest_signal_up(
		 int pc,
		 int regs_0,  int regs_1,  int regs_2,  int regs_3,
		 int regs_4,  int regs_5,  int regs_6,  int regs_7,
		 int regs_8,  int regs_9,  int regs_10,  int regs_11,
		 int regs_12,  int regs_13,  int regs_14,  int regs_15,
		 int regs_16,  int regs_17,  int regs_18,  int regs_19,
		 int regs_20,  int regs_21,  int regs_22,  int regs_23,
		 int regs_24,  int regs_25,  int regs_26,  int regs_27,
		 int regs_28,  int regs_29,  int regs_30,  int regs_31,
		 int csr_0,  int csr_1,  int csr_2,  int csr_3
	)
	{

	}
}
