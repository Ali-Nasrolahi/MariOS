ENTRY(_start)
/* OUTPUT_ARCH(i386) */
OUTPUT_FORMAT(binary)

MEMORY {
    RAM (rwx) : ORIGIN = 0x7c00, LENGTH = 440
}

SECTIONS
{
    .text :
    {
        *(.text)
        *(.text*)
    } > RAM

    /DISCARD/ : {
        *(.debug*)
        *(.comment*)
    }
}