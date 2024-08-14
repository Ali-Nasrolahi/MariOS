#pragma once

#include "x86.h"

#define SECT_SIZE (512)

void ata_lba_read(uint32_t addr, void *buf, uint8_t sect);
void ata_lba_write(uint32_t addr, void *buf, uint8_t sect);