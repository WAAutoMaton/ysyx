#include "dpi.h"
extern "C" {
	bool is_ebreak;
	void ebreak(void)
	{
		is_ebreak=true;
	}
}
