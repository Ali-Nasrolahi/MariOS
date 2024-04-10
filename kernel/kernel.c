#include "kernel.h"

void clear_screen()
{
    volatile uint16_t *where;
    where = (volatile uint16_t *)0xb8000;

    for (int i = 0; i < (1 << 10); ++i)
        where[i] = 0;
}

void writec(unsigned char c, unsigned char forecolour, unsigned char backcolour, int x, int y)
{
    uint16_t attrib = (backcolour << 4) | (forecolour & 0x0F);
    volatile uint16_t *where;
    where = (volatile uint16_t *)0xb8000 + (y * 80 + x);
    *where = c | (attrib << 8);
}

void writes(const char *s, unsigned char forecolour, unsigned char backcolour, int x, int y)
{
    for (int i = 0; s[i]; ++i) {
        writec(s[i], forecolour, backcolour, x++, y);
    }
}

void kmain()
{
    clear_screen();
    writes("hello world", 0xa, 5, 0, 0);
}