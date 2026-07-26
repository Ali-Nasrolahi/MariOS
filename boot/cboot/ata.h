#pragma once

#include "x86.h"

#define SECT_SIZE (512)

/*
 * TODO: (IMPORTANT)
 * There's some weird bug, that when i do immediate write to then read from same address
 * _most of the times_ NULL returns by ATA device and not the value that I just wrote.
 * not sure why?
 * Tested by both assembly and C implementation.
 */

/* C Implementations */
int8_t ata_lba_read(uint32_t addr, void *buf, uint8_t sect);
int8_t ata_lba_write(uint32_t addr, void *buf, uint8_t sect);

/* Assembly Implementations */
int32_t __attribute__((cdecl)) _ata_lba_read(uint32_t addr, void *buf, uint8_t sect);
int32_t __attribute__((cdecl)) _ata_lba_write(uint32_t addr, void *buf, uint8_t sect);
void __attribute__((cdecl)) _ata_software_reset(void);