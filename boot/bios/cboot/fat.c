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

/*
 * TODO
 * I need more delicate approach to remove repeated iteration code.
 * Callbacks needs to more generic, I need to ba ablate to pass list of args
 * to them (maybe by va_list and forwarding args from iterator to callbacks).
 *
 */
#if 0

static fat_dir_ent_t fat_iterate_rootdir(bool (*callback)(fat_dir_ent_t *ent))
{
    fat_dir_list list;
    uint8_t off = 0;

next_list:
    fat_load_dir_list(list, off++);
    for (size_t i = 0; i < sizeof(list) / sizeof(*list) && list[i].filename[0]; ++i) {
        if (callback(&list[i]) == FAT_ITER_CNTRL_BREAK)
            return list[i];
    }

    if (list[sizeof(list) / sizeof(*list) - 1].filename[0])
        goto next_list;

    return (fat_dir_ent_t){0};
}
static bool fat_print_files_cb(fat_dir_ent_t *ent)
{
    /* Ignore long file names and empty entries*/
    if (_nth_byte_of(ent, 11) != 0xf && ((unsigned char)ent->filename[0]) != 0xe5) {
        puts(ent->filename);
        puts("\n");
    }

    return FAT_ITER_CNTRL_CONT;
}

static bool fat_find_file_cb(fat_dir_ent_t *ent)
{
    /* Ignore long file names and empty entries*/
    if (_nth_byte_of(ent, 11) != 0xf && ((unsigned char)ent->filename[0]) != 0xe5) {
        puts(ent->filename);
        puts("\n");
    }

    return FAT_ITER_CNTRL_CONT;
}

void fat_print_files() { fat_iterate_rootdir(fat_print_files_cb); }
#endif

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

int32_t fat_find_entry(const char *filename)
{
    static fat_dir_list list;
    uint8_t off = 0;

next_list:
    fat_load_dir_list(list, off++);
    /* TODO FIX comparaison bug */
    for (size_t i = 0; i < sizeof(list) / sizeof(*list) && list[i].filename[0]; ++i) {
        if (!strncmp(((char *)&(list[i])), filename, 11))
            // if (!strncmp(list[i].filename, filename, 8) &&
            //  !strncmp(list[i].extension, filename + 8 /* extension part*/, 3))
            return (list[i].first_cluster_hi << 16) | list[i].first_cluster_lo;
    }

    if (list[sizeof(list) / sizeof(*list) - 1].filename[0])
        goto next_list;

    return -1;
}