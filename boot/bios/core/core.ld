ENTRY(_start)
OUTPUT_FORMAT(binary)

MEMORY {
    RAM (rwx) : ORIGIN = 0x0600, LENGTH = 4k
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