ENTRY(_start)
OUTPUT_FORMAT(binary)
OUTPUT(cboot.bin)

SECTIONS
{
    . = 0x8e00;
    .bootsect :
    {
        *(.boot)
        *(.boot*)
    }

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