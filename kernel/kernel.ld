ENTRY(kmain)
OUTPUT_FORMAT(binary)

SECTIONS
{
    . = 0x1000;

    .text :
    {
        *(.text)
    }

    .rodata :
    {
        *(.rodata)
    }

    .data :
    {
        *(.bss)
    }

    .bss :
    {
        *(COMMON)
        *(.text)
    }

}