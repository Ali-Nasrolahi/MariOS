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

void fat_init(uint32_t p_lba)
{
    uint8_t __attribute__((aligned(16))) buf[1 * SECT_SIZE];

    _ata_lba_read(p_lba, buf, 1);
    memcpy(&fat_bpb, buf, sizeof(fat_bpb_t));

    fat_meta.partition_lba = p_lba;

    fat_meta.total_sectors =
        (fat_bpb.total_sectors_16 == 0) ? fat_bpb.total_sectors_32 : fat_bpb.total_sectors_16;

    /* TODO: Handle FAT32 */
    fat_meta.size = fat_bpb.table_size_16;

    /* Determine Regions Meta data */
    fat_meta.first_fat_sector = fat_bpb.reserved_sector_count;
    fat_meta.fat_sectors = fat_bpb.table_count;

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
    fat_dir_list list;
    uint8_t off = 0;

next_list:
    fat_load_dir_list(list, off++);
    for (size_t i = 0; i < sizeof(list) / sizeof(*list) && list[i].filename[0]; ++i) {
        if (!strncmp(((char *)&(list[i])), filename, 11))
            return (list[i].first_cluster_hi << 16) | list[i].first_cluster_lo;
    }

    if (list[sizeof(list) / sizeof(*list) - 1].filename[0]) goto next_list;

    return -1;
}

uint8_t fat_load_cls_chain(uint32_t clsno, void *dst, size_t size_in_cluster)
{
    uint8_t __attribute__((aligned(16))) fat_table[1 * SECT_SIZE];
    uint8_t fat_sect = fat_meta.first_fat_sector + (clsno * 2 / SECT_SIZE);
    uint8_t ent_offset = (clsno * 2) % SECT_SIZE;

    if (!size_in_cluster /* not enough space left */) return FAT_SMALL_BUFFER;
    if (clsno < 3 /* Wrong cluster index */) return FAT_BAD_CLUSTER;

    {
        /* Load current cluster */
        uint32_t first_sect =
            (clsno - 2) * fat_bpb.sectors_per_cluster + fat_meta.first_data_sector;
        _ata_lba_read(fat_meta.partition_lba + first_sect, dst, fat_bpb.sectors_per_cluster);
    }

    /* Load FAT table to determine next step */
    _ata_lba_read(fat_meta.partition_lba + fat_sect, fat_table, 1);
    clsno = *(uint16_t *)&fat_table[ent_offset];

    if (clsno >= 0xFFF8 /* last cluster */) return FAT_SUCCESSFUL_LOAD;
    else if (clsno == 0xFFF7 /* bad cluster */) return FAT_CORRUPT_CLUSTER;

    /*
     * One cluster has loaded, for next one
     * we need to move buffer to next cluster position and
     * decrement size of buffer by 1.
     */
    return fat_load_cls_chain(
        clsno, ((uint8_t *)dst + fat_bpb.sectors_per_cluster * fat_bpb.bytes_per_sector),
        --size_in_cluster);
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
