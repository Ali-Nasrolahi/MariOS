#include "print.h"

typedef struct {
    uint8_t x;
    uint8_t y;
} __screen_cursor;

static void __putc(char c)
{

    static __screen_cursor _cursor;

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
}

void puts(char *c)
{
    while (*c)
        __putc(*c++);
}