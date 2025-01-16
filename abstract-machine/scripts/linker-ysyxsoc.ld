ENTRY(_start)
PHDRS { text PT_LOAD; data PT_LOAD; }
MEMORY {
  /*mrom : ORIGIN = 0x20000000, LENGTH = 4K*/
  flash : ORIGIN = 0x30000000, LENGTH = 1M
  sram : ORIGIN = 0x0f000000, LENGTH = 8K
}
SECTIONS {
  /* _pmem_start and _entry_offset are defined in LDFLAGS */
  /*. = _pmem_start + _entry_offset;*/
  . = ORIGIN(flash);
  .text : {
    *(entry)
    *(.text*)
    _text_end = .;
  } > flash AT> flash : text
  etext = .;
  _etext = .;
  .rodata : {
    *(.rodata*)
    *(.srodata*)
  } > flash AT>flash
  _m_data_start = .;
  .data : {
    _data_start = .;
    *(.data*)
    *(.sdata*)
    _data_end = .;
  } > sram AT>flash : data
  edata = .;
  _data = .;
  .bss : {
    _bss_start = .;
    *(.bss*)
    *(.sbss*)
    *(.scommon)
    _bss_end = .;
  } > sram AT> flash
  _heap_start = ALIGN(0x10);
  . =  _heap_start + 0x500;
  _heap_end = .;
  _stack_top = 0x0f001200;
  . = _stack_top + 0x800;
  _stack_pointer = .;
  end = .;
  _end = .;
}
