#pragma once

#include "x86.h"

#define SECT_SIZE (512)

/*
 * Buggy, I don't know why though right now.
 * Use Assembly siblings for now.
 */
void ata_lba_read(uint32_t addr, void *buf, uint8_t sect) __attribute__((deprecated));
void ata_lba_write(uint32_t addr, void *buf, uint8_t sect) __attribute__((deprecated));

void __attribute__((cdecl)) _ata_lba_read(uint32_t addr, void *buf, uint8_t sect);
void __attribute__((cdecl)) _ata_lba_write(uint32_t addr, void *buf, uint8_t sect);