#include "ata.h"

void ata_lba_read(uint32_t addr, void *buf, uint8_t sect)
{
    outb(0x1f2, sect);
    outb(0x1f3, (uint8_t)addr);
    outb(0x1f4, (uint8_t)(addr >> 8));
    outb(0x1f5, (uint8_t)(addr >> 16));
    outb(0x1f6, 0xe0 | ((uint8_t)(addr >> 24) & 0xf));
    outb(0x1f7, 0x20);

    for (uint8_t status = 0; status & 0x8; status = inb(0x1f7))
        ;

    rep_insw(0x1f0, buf, sect * 256);
}

void ata_lba_write(uint32_t addr, void *buf, uint8_t sect)
{
    outb(0x1f2, sect);
    outb(0x1f3, (uint8_t)addr);
    outb(0x1f4, (uint8_t)(addr >> 8));
    outb(0x1f5, (uint8_t)(addr >> 16));
    outb(0x1f6, 0xe0 | ((uint8_t)(addr >> 24) & 0xf));
    outb(0x1f7, 0x30);

    for (uint8_t status = 0; status & 0x8; status = inb(0x1f7))
        ;

    rep_outsw(0x1f0, buf, sect * 256);
}