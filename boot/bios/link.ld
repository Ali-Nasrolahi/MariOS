ENTRY(_start)
OUTPUT_FORMAT(binary)
OUTPUT(cboot.bin)

SECTIONS
{
    . = 0x8e00;
    .bootsect :
    {
        __bootsect_begin = .;

        *(.boot)
        *(.boot*)

        __bootsect_end = .;
    }

    .text :
    {
        . = ALIGN(512);
        __text_begin = .;

        *(.text)
        *(.text*)

        __text_end = .;
    }

    .data :
    {
        __data_begin = .;
        *(.data)
        __data_end = .;
    }

    .bss :
    {
        __bss_begin = .;
        *(.bss)
        __bss_end = .;
    }

    .rodata :
    {
        __rodata_begin = .;
        *(.rodata)
        __rodata_end = .;
    }

    /DISCARD/ : {
        *(.debug*)
        *(.comment*)
    }
}