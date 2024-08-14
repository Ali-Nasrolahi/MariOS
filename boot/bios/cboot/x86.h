#pragma once

#include <stdint.h>

void __attribute__((cdecl)) outb(uint16_t port, uint8_t val);
uint8_t __attribute__((cdecl)) inb(uint16_t port);

void __attribute__((cdecl)) rep_outsw(uint16_t port, void *buf, uint32_t size);
void __attribute__((cdecl)) rep_insw(uint16_t port, void *buf, uint32_t size);