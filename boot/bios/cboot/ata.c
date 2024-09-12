#include "ata.h"

int8_t ata_lba_read(uint32_t addr, void *buf, uint8_t sect)
{
    uint8_t status = 0;
    uint8_t *buf_ = (uint8_t *)buf;  // pinter + offset to original buffer

    outb(0x1f2, sect);
    outb(0x1f3, (uint8_t)addr);
    outb(0x1f4, (uint8_t)(addr >> 8));
    outb(0x1f5, (uint8_t)(addr >> 16));
    outb(0x1f6, 0xe0 | ((uint8_t)(addr >> 24) & 0xf));
    outb(0x1f7, 0x20);

    for (; sect--;) {
        /*
         * BSY should clears
         * Technically, when BSY is set, the other bits in the Status byte are meaningless
         */
        for (status = inb(0x1f7); status & 0x80; status = inb(0x1f7));

        if (status & 0x21 /* ERR flag */ || !(status & 0x8) /* DRQ not set */) return -1;

        // Read 1 sector
        rep_insw(0x1f0, buf, 256);

        // delay 400ns
        inb(0x1f7);
        inb(0x1f7);
        inb(0x1f7);
        inb(0x1f7);

        // Move one sector ahead
        buf_ += 512;
    }

    return 0;
}

int8_t ata_lba_write(uint32_t addr, void *buf, uint8_t sect)
{
    uint8_t status = 0;
    uint8_t *buf_ = (uint8_t *)buf;  // pinter + offset to original buffer

    outb(0x1f2, sect);
    outb(0x1f3, (uint8_t)addr);
    outb(0x1f4, (uint8_t)(addr >> 8));
    outb(0x1f5, (uint8_t)(addr >> 16));
    outb(0x1f6, 0xe0 | ((uint8_t)(addr >> 24) & 0xf));
    outb(0x1f7, 0x30);

    for (; sect--;) {
        /*
         * BSY should clears
         * Technically, when BSY is set, the other bits in the Status byte are meaningless
         */
        for (status = inb(0x1f7); status & 0x80; status = inb(0x1f7));

        if (status & 0x21 /* ERR flag */ || !(status & 0x8) /* DRQ not set */) return -1;

        // Write 1 sector
        rep_outsw(0x1f0, buf_, 256);

        // delay 400ns
        inb(0x1f7);
        inb(0x1f7);
        inb(0x1f7);
        inb(0x1f7);

        // Move one sector ahead
        buf_ += 512;
    }

    return 0;
}