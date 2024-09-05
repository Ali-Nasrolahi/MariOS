#include "print.h"
#include "x86.h"

typedef struct {
    uint8_t x;
    uint8_t y;
} __screen_cursor;

static __screen_cursor _cursor;

static void __enable_cursor(uint8_t cursor_start, uint8_t cursor_end)
{
    outb(0x3D4, 0x0A);
    outb(0x3D5, (inb(0x3D5) & 0xC0) | cursor_start);

    outb(0x3D4, 0x0B);
    outb(0x3D5, (inb(0x3D5) & 0xE0) | cursor_end);
}

static void __update_cursor(uint8_t x, uint8_t y)
{
    uint16_t pos = y * __DISPLAY_WIDTH__ + x;

    outb(0x3D4, 0x0F);
    outb(0x3D5, (uint8_t)(pos & 0xFF));
    outb(0x3D4, 0x0E);
    outb(0x3D5, (uint8_t)((pos >> 8) & 0xFF));
}

static void __putc(char c)
{
    switch (c) {
    case '\n':
        ++_cursor.y;
        __attribute__((fallthrough));
    case '\r':
        _cursor.x = 0;
        goto skip_writing_on_screen;
        break;

    case '\t':
        _cursor.x += 4;
        goto skip_writing_on_screen;
        break;

    default:
        break;
    }
    __VIDEO_MEMORY__MAP__[2 * (_cursor.y * __DISPLAY_WIDTH__ + _cursor.x++)] = c;

skip_writing_on_screen:

    if (_cursor.x > __DISPLAY_WIDTH__)
        __putc('\n');

    if (_cursor.y > __DISPLAY_HEIGHT__)
        _cursor.y = _cursor.x = 0;
    __update_cursor(_cursor.x, _cursor.y);
}

void putc(char c) { __putc(c); }

void puts(char *c)
{
    while (*c) putc(*c++);
}

void clear_screen()
{
    uint16_t pixels = __DISPLAY_HEIGHT__ * __DISPLAY_WIDTH__;
    while (pixels--) __putc(' ');
    *((uint16_t *)&_cursor) = 0;
    __enable_cursor(0, 15);
    __update_cursor(0, 0);
}