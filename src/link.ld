ENTRY(_start)

SECTIONS
{
  . = 0x10000;
  .text : { *(.text*) }
  .rodata : { *(.rodata*) }
  .data : { *(.data*) }
  .bss : { *(.bss*) }
  /DISCARD/ : { *(.comment) *(.eh_frame*) }
  . = ALIGN(8);
  PROVIDE(end = .);
}

