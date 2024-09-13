ENTRY(_kmain)

SECTIONS
{
    .text :
    {
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
}
