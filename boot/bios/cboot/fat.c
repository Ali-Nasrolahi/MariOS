#include "fat.h"
#include "ata.h"
#include "print.h"

static fat_bpb_t __attribute__((aligned(16))) fat_bpb;
static fat_metadata_t fat_meta;

static inline uint32_t __attribute__((const)) fat_get_cls_sect(uint32_t cls)
{
    return ((cls - 2) * fat_bpb.sectors_per_cluster) + fat_meta.first_data_sector;
}

void fat_init(uint32_t p_lba)
{
    uint8_t __attribute__((aligned(16))) buf[1 * SECT_SIZE];

    ata_lba_read(p_lba, buf, 1);
    memcpy(&fat_bpb, buf, sizeof(fat_bpb_t));

    fat_meta.partition_lba = p_lba;
    fat_meta.total_sectors =
        (fat_bpb.total_sectors_16 == 0) ? fat_bpb.total_sectors_32 : fat_bpb.total_sectors_16;

    /* TODO: Handler FAT32 */
    fat_meta.size = fat_bpb.table_size_16;

    fat_meta.root_dir_sectors = ((fat_bpb.root_entry_count * 32) + (fat_bpb.bytes_per_sector - 1)) /
                                fat_bpb.bytes_per_sector;

    fat_meta.first_data_sector = fat_bpb.reserved_sector_count +
                                 (fat_bpb.table_count * fat_meta.size) + fat_meta.root_dir_sectors;

    fat_meta.data_sectors = fat_meta.total_sectors -
                            (fat_bpb.reserved_sector_count + (fat_bpb.table_count * fat_meta.size) +
                             fat_meta.root_dir_sectors);

    fat_meta.total_clusters = fat_meta.data_sectors / fat_bpb.sectors_per_cluster;

    /* TODO Not correct value */
    if (fat_meta.data_sectors == (552 - p_lba / 512))
        puts("VAlueSeen\n");
}
