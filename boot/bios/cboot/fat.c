#include "fat.h"
#include "print.h"

/* Global Driver Parameters */

static fat_bpb_t __attribute__((aligned(16))) fat_bpb;
static fat_metadata_t fat_meta;

/* Global Driver Parameters */

static inline uint32_t __attribute__((const)) fat_get_cls_sect(uint32_t cls)
{
    return ((cls - 2) * fat_bpb.sectors_per_cluster) + fat_meta.first_data_sector;
}

static void fat_load_dir_list(fat_dir_list list, uint16_t offset)
{
    _ata_lba_read(fat_meta.partition_lba + fat_meta.first_rootdir_sector + offset, list, 1);
}

static void fat_iterate_rootdir(bool (*callback)(fat_dir_ent_t *ent))
{
    fat_dir_list list;
    uint8_t off = 0;

next_list:
    fat_load_dir_list(list, off++);
    for (size_t i = 0; i < sizeof(list) / sizeof(*list) && list[i].filename[0]; ++i) {
        if (!callback(&list[i]))
            return;
    }

    if (list[sizeof(list) / sizeof(*list) - 1].filename[0])
        goto next_list;
}

static bool fat_print_files_cb(fat_dir_ent_t *ent)
{
    /* Ignore long file names and empty entries*/
    if (_nth_byte_of(ent, 11) != 0xf && ((unsigned char)ent->filename[0]) != 0xe5) {
        puts(ent->filename);
        puts("\n");
    }
    return true;
}

void fat_init(uint32_t p_lba)
{
    uint8_t __attribute__((aligned(16))) buf[1 * SECT_SIZE];

    _ata_lba_read(p_lba, buf, 1);
    memcpy(&fat_bpb, buf, sizeof(fat_bpb_t));

    fat_meta.partition_lba = p_lba;
    fat_meta.total_sectors =
        (fat_bpb.total_sectors_16 == 0) ? fat_bpb.total_sectors_32 : fat_bpb.total_sectors_16;

    /* TODO: Handler FAT32 */
    fat_meta.size = fat_bpb.table_size_16;

    fat_meta.rootdir_sectors = ((fat_bpb.root_entry_count * 32) + (fat_bpb.bytes_per_sector - 1)) /
                               fat_bpb.bytes_per_sector;

    fat_meta.first_data_sector = fat_bpb.reserved_sector_count +
                                 (fat_bpb.table_count * fat_meta.size) + fat_meta.rootdir_sectors;

    fat_meta.data_sectors =
        fat_meta.total_sectors - (fat_bpb.reserved_sector_count +
                                  (fat_bpb.table_count * fat_meta.size) + fat_meta.rootdir_sectors);

    fat_meta.total_clusters = fat_meta.data_sectors / fat_bpb.sectors_per_cluster;

    fat_meta.first_rootdir_sector = fat_meta.first_data_sector - fat_meta.rootdir_sectors;
}

uint32_t fat_find_entry(const char *filename) { return 0; }

void fat_print_files() { fat_iterate_rootdir(fat_print_files_cb); }