#pragma once

#include <stddef.h>
#include <stdint.h>

void __attribute__((cdecl)) outb(uint16_t port, uint8_t val);
uint8_t __attribute__((cdecl)) inb(uint16_t port);

void __attribute__((cdecl)) rep_outsw(uint16_t port, void *buf, size_t size);
void __attribute__((cdecl)) rep_insw(uint16_t port, void *buf, size_t size);

static inline void *memcpy(void *restrict dest, const void *restrict src, size_t count)
{
    __asm__("cld");
    __asm__("rep movsb" : "+c"(count), "+S"(src), "+D"(dest)::"memory");
    return dest;
}

static inline void *memset(void *b, int val, size_t count)
{
    __asm__("cld");
    __asm__("rep stosb" : "+c"(count), "+D"(b) : "a"(val) : "memory");
    return b;
}
