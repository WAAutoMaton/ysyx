/***************************************************************************************
* Copyright (c) 2014-2022 Zihao Yu, Nanjing University
*
* NEMU is licensed under Mulan PSL v2.
* You can use this software according to the terms and conditions of the Mulan PSL v2.
* You may obtain a copy of Mulan PSL v2 at:
*          http://license.coscl.org.cn/MulanPSL2
*
* THIS SOFTWARE IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
* EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
* MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
*
* See the Mulan PSL v2 for more details.
***************************************************************************************/

#include <memory/host.h>
#include <memory/paddr.h>
#include <device/mmio.h>
#include <isa.h>

#if   defined(CONFIG_PMEM_MALLOC)
static uint8_t *pmem = NULL;
#else // CONFIG_PMEM_GARRAY
static uint8_t pmem[CONFIG_MSIZE] PG_ALIGN = {};
#endif
static uint8_t mrom[1024*8] PG_ALIGN = {};

uint8_t* guest_to_host(paddr_t paddr) { 
  if (in_flash(paddr)) {
    return flash + paddr - FLASH_BASE;
  }
  else if (in_psram(paddr)) {
    return psram + paddr - PSRAM_BASE;
  }
  else if (in_mrom(paddr)) {
    return mrom + paddr - MROM_BASE;
  }
  else if (in_sram(paddr)) {
    return sram + paddr - SRAM_BASE;
  }
  else if (in_sdram(paddr)) {
    return sdram + paddr - SDRAM_BASE;
  }
  return pmem + paddr - CONFIG_MBASE; 
}
paddr_t host_to_guest(uint8_t *haddr) { 
  if (phy_in_mrom(haddr)) {
    return haddr - mrom + MROM_BASE;
  }
  else if (phy_in_sram(haddr)) {
    return haddr - sram + SRAM_BASE;
  }
  else if (phy_in_sdram(haddr)) {
    return haddr - sdram + SDRAM_BASE;
  }
  else if (phy_in_flash(haddr)) {
    return haddr - flash + FLASH_BASE;
  }
  else if (phy_in_psram(haddr)) {
    return haddr - psram + PSRAM_BASE;
  }
  return haddr - pmem + CONFIG_MBASE; 
}

static word_t pmem_read(paddr_t addr, int len) {
  if (addr >= 0x20000000 && addr <= 0x20000fff) {
    return host_read(mrom+addr-0x20000000, len);
  }
  word_t ret = host_read(guest_to_host(addr), len);
  return ret;
}

static void pmem_write(paddr_t addr, int len, word_t data) {
  if (addr >= 0x20000000 && addr <= 0x20000fff) {
    return host_write(mrom+addr-0x20000000, len, data);
  }
  host_write(guest_to_host(addr), len, data);
}

__attribute__((noreturn)) static void out_of_bound(paddr_t addr) {
  panic("address = " FMT_PADDR " is out of bound of pmem [" FMT_PADDR ", " FMT_PADDR "] at pc = " FMT_WORD,
      addr, PMEM_LEFT, PMEM_RIGHT, cpu.pc);
}

void init_mem(const uint8_t *mrom_ref, int mrom_size) {
#if   defined(CONFIG_PMEM_MALLOC)
  pmem = malloc(CONFIG_MSIZE);
  assert(pmem);
#endif
  memcpy(mrom, mrom_ref, mrom_size);
  IFDEF(CONFIG_MEM_RANDOM, memset(pmem, rand(), CONFIG_MSIZE));
  Log("physical memory area [" FMT_PADDR ", " FMT_PADDR "]", PMEM_LEFT, PMEM_RIGHT);
}

word_t paddr_read(paddr_t addr, int len) {
  word_t res;
  if (likely(in_pmem(addr))) res= pmem_read(addr, len);
  else {
    IFDEF(CONFIG_DEVICE, res = mmio_read(addr, len));
    IFNDEF(CONFIG_DEVICE, out_of_bound(addr));
  }
#ifdef CONFIG_MTRACE
  log_write("paddr_read: addr = " FMT_PADDR ", len = %d, data = " FMT_WORD "\n", addr, len, res);
#endif
  return res;
}

void paddr_write(paddr_t addr, int len, word_t data) {
#ifdef CONFIG_MTRACE
  log_write("paddr_write: addr = " FMT_PADDR ", len = %d, data = " FMT_WORD "\n", addr, len, data);
#endif
  if (likely(in_pmem(addr))) { pmem_write(addr, len, data); return; }
  IFDEF(CONFIG_DEVICE, mmio_write(addr, len, data); return);
  out_of_bound(addr);
}
