ENTRY(_start)
OUTPUT_FORMAT(binary)
OUTPUT(cboot.bin)

SECTIONS
{
    . = 0x7c00;
    .bootsect :
    {
        *(.boot)
        *(.boot*)
    }

    . = 0x7e00;
    .text :
    {
        . = ALIGN(512);
        *(.text)
        *(.text*)
    }

    .data :
    {
        *(.data)
    }

    .bss :
    {
        *(.bss)
    }

    .rodata :
    {
        *(.rodata)
    }

    /DISCARD/ : {
        *(.debug*)
        *(.comment*)
    }
}