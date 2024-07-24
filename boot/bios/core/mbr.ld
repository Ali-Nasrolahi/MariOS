ENTRY(_start)
OUTPUT_FORMAT(binary)

MEMORY {
    RAM (wx) : ORIGIN = 0x7c00, LENGTH = 446
}

SECTIONS
{
    .all :
    {
        *
    } > RAM
}