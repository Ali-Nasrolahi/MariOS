ENTRY(_start)
OUTPUT_FORMAT(binary)

MEMORY {
    RAM (wx) : ORIGIN = 0x6c00, LENGTH = 4k
}

SECTIONS
{
    .all :
    {
        *
    } > RAM

}