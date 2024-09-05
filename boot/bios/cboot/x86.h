#pragma once

#include <stdbool.h>
#include <stddef.h>
#include <stdint.h>

#define _nth_byte_of(_ptr, n) (((uint8_t *)_ptr)[n])

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

static inline int strcmp(const char *a, const char *b)
{
    while (*a && *a == *b && ++a && ++b);
    return *a ? (unsigned char)(*a) - (unsigned char)(*b) : 0;
}

static inline int strncmp(const char *a, const char *b, size_t size)
{
    while (--size && *a && *a == *b && ++a && ++b);
    return *a ? (unsigned char)(*a) - (unsigned char)(*b) : 0;
}