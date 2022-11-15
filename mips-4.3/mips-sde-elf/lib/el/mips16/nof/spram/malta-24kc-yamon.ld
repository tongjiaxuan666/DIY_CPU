/* Linker script for malta-24kc
 *
 * Version:Sourcery G++ Lite 4.3-81
 * BugURL:https://support.codesourcery.com/GNUToolchain/
 *
 * Copyright 2007, 2008 CodeSourcery, Inc.
 *
 * The authors hereby grant permission to use, copy, modify, distribute,
 * and license this software and its documentation for any purpose, provided
 * that existing copyright notices are retained in all copies and that this
 * notice is included verbatim in any distributions.  No written agreement,
 * license, or royalty fee is required for any of the authorized uses.
 * Modifications to this software may be copyrighted by their authors
 * and need not follow the licensing terms described here, provided that
 * the new terms are clearly indicated on the first page of each file where
 * they apply.
 * */
OUTPUT_ARCH(mips)
ENTRY(_start)
SEARCH_DIR(.)
GROUP(-lcs3hal -lgcc -lc -lcs3 -lcs3yamon)

MEMORY
{
  ram (rwx) : ORIGIN = 0x80000000 + 1M, LENGTH = 128M - 1M
}

/* These force the linker to search for particular symbols from
 * the start of the link process and thus ensure the user's
 * overrides are picked up
 */
EXTERN(__cs3_reset_malta_24kc_yamon)
EXTERN(__cs3_start_c main __cs3_stack __cs3_heap_end)
/* force exit to be picked up in a hosted or os environment */
EXTERN(exit atexit)

PROVIDE(__cs3_heap_start = _end);
PROVIDE(__cs3_heap_end = __cs3_region_start_ram + __cs3_region_size_ram);
PROVIDE(__cs3_region_num = (__cs3_regions_end - __cs3_regions) / 20);
/* Define where the yamon entry point table is */
__cs3_yamon_functions = 0x9fc00500;
/* We want newlib to register finalizers.  */
__libc_fini = _fini;
/* The startup code knows to inherit the provided stack.  */
PROVIDE (__cs3_stack = 0);

SECTIONS
{

  .text :
  {
    CREATE_OBJECT_SYMBOLS
    __cs3_region_start_ram = .;
    *(.cs3.region-head.ram)
    ASSERT (. == __cs3_region_start_ram, ".cs3.region-head.ram not permitted");

    _start = __cs3_reset_malta_24kc_yamon;
    __cs3_reset = __cs3_reset_malta_24kc_yamon;
    *(.cs3.reset)
    /* Make sure we pulled in some reset code.  */
    ASSERT (. != __cs3_reset, "No reset code");

    *(.text .text.* .gnu.linkonce.t.*)

    . = ALIGN(0x4);
    KEEP (*crtbegin.o(.jcr))
    KEEP (*(EXCLUDE_FILE (*crtend.o) .jcr))
    KEEP (*crtend.o(.jcr))

    . = ALIGN(0x4);
    *(.gcc_except_table .gcc_except_table.*)
  } >ram
  .eh_frame_hdr : ALIGN (4)
  {
    KEEP (*(.eh_frame_hdr))
  } >ram
  .eh_frame : ALIGN (4)
  {
    KEEP (*(.eh_frame))
  } >ram
  /* MDI semihosting uses a pointer in this section.  */
  .sdeosabi : ALIGN (4)
  {
    *(.sdeosabi)
  } >ram
  .rodata : ALIGN (4)
  {
    *(.rodata .rodata.* .gnu.linkonce.r.*)

    . = ALIGN(4);
    KEEP(*(.init))

    . = ALIGN(4);
    __preinit_array_start = .;
    KEEP (*(.preinit_array))
    __preinit_array_end = .;

    . = ALIGN(4);
    __init_array_start = .;
    KEEP (*(SORT(.init_array.*)))
    KEEP (*(.init_array))
    __init_array_end = .;

    . = ALIGN(4);
    KEEP(*(.fini))

    . = ALIGN(4);
    __fini_array_start = .;
    KEEP (*(.fini_array))
    KEEP (*(SORT(.fini_array.*)))
    __fini_array_end = .;

    . = ALIGN(0x4);
    KEEP (*crtbegin.o(.ctors))
    KEEP (*(EXCLUDE_FILE (*crtend.o) .ctors))
    KEEP (*(SORT(.ctors.*)))
    KEEP (*crtend.o(.ctors))

    . = ALIGN(0x4);
    KEEP (*crtbegin.o(.dtors))
    KEEP (*(EXCLUDE_FILE (*crtend.o) .dtors))
    KEEP (*(SORT(.dtors.*)))
    KEEP (*crtend.o(.dtors))

    *(.lit)

    . = ALIGN(4);
    __cs3_regions = .;
    LONG (0)
    LONG (__cs3_region_init_ram)
    LONG (__cs3_region_start_ram)
    LONG (__cs3_region_init_size_ram)
    LONG (__cs3_region_zero_size_ram)
    __cs3_regions_end = .;

    . = ALIGN (8);
    . = ALIGN (8);
    _etext = .;
  } >ram

  .data : ALIGN (8)
  {

    *(.got.plt) *(.got)
    *(.shdata)
    *(.data .data.* .gnu.linkonce.d.*)
    . = ALIGN(8);
    _gp = . + 0x8000;
    *(.lit8)
    *(.lit4)
    *(.sdata .sdata.* .gnu.linkonce.s.*)
    . = ALIGN (8);
    *(.ram)
    _edata = .;
  } >ram
  .bss :
  {
    *(.sbss .sbss.* .gnu.linkonce.sb.*)
    *(.scommon)
    *(.shbss)
    *(.bss .bss.* .gnu.linkonce.b.*)
    *(COMMON)
    . = ALIGN (8);
    *(.ram.b)
    _end = .;
    __end = .;
  } >ram
  __cs3_region_init_ram = __cs3_region_start_ram;
  __cs3_region_init_size_ram = _edata - __cs3_region_start_ram;
  __cs3_region_zero_size_ram = _end - _edata;
  /* Default to 1M of heap */
  __cs3_region_size_ram = ALIGN (1024) - . + 1M;

  .stab 0 (NOLOAD) : { *(.stab) }
  .stabstr 0 (NOLOAD) : { *(.stabstr) }
  /* DWARF debug sections.
   * Symbols in the DWARF debugging sections are relative to the beginning
   * of the section so we begin them at 0.  */
  /* DWARF 1 */
  .debug          0 : { *(.debug) }
  .line           0 : { *(.line) }
  /* GNU DWARF 1 extensions */
  .debug_srcinfo  0 : { *(.debug_srcinfo) }
  .debug_sfnames  0 : { *(.debug_sfnames) }
  /* DWARF 1.1 and DWARF 2 */
  .debug_aranges  0 : { *(.debug_aranges) }
  .debug_pubnames 0 : { *(.debug_pubnames) }
  /* DWARF 2 */
  .debug_info     0 : { *(.debug_info .gnu.linkonce.wi.*) }
  .debug_abbrev   0 : { *(.debug_abbrev) }
  .debug_line     0 : { *(.debug_line) }
  .debug_frame    0 : { *(.debug_frame) }
  .debug_str      0 : { *(.debug_str) }
  .debug_loc      0 : { *(.debug_loc) }
  .debug_macinfo  0 : { *(.debug_macinfo) }
  /* SGI/MIPS DWARF 2 extensions */
  .debug_weaknames 0 : { *(.debug_weaknames) }
  .debug_funcnames 0 : { *(.debug_funcnames) }
  .debug_typenames 0 : { *(.debug_typenames) }
  .debug_varnames  0 : { *(.debug_varnames) }
}
