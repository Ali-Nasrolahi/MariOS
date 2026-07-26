/**
 * @file fat.h
 * @author Ali Nasrolahi (a.nasrolahi01@gmail.com)
 * @brief Simple FAT routines based on https://wiki.osdev.org/FAT
 * @date 2024-08-15
 */
#pragma once

#include "ata.h"
#include "x86.h"

#define FAT_ROOTDIR_ENT_SIZE      (32)
#define FAT_CLUSTER_SIZE_IN_BYTES (8 * SECT_SIZE)

#define FAT_ITER_CNTRL_CONT  (true)
#define FAT_ITER_CNTRL_BREAK (false)

enum fat_load_cls_chain_status_e {
    FAT_SUCCESSFUL_LOAD,
    FAT_SMALL_BUFFER,
    FAT_BAD_CLUSTER,
    FAT_CORRUPT_CLUSTER,
};

typedef struct {
    // extended fat32 stuff
    uint32_t table_size_32;
    uint16_t extended_flags;
    uint16_t fat_version;
    uint32_t root_cluster;
    uint16_t fat_info;
    uint16_t backup_BS_sector;
    uint8_t reserved_0[12];
    uint8_t drive_number;
    uint8_t reserved_1;
    uint8_t boot_signature;
    uint32_t volume_id;
    uint8_t volume_label[11];
    uint8_t fat_type_label[8];

} __attribute__((packed)) fat_extBS_32_t;

typedef struct {
    // extended fat12 and fat16 stuff
    uint8_t bios_drive_num;
    uint8_t reserved1;
    uint8_t boot_signature;
    uint32_t volume_id;
    uint8_t volume_label[11];
    uint8_t fat_type_label[8];

} __attribute__((packed)) fat_extBS_16_t;

typedef struct {
    uint8_t bootjmp[3];
    uint8_t oem_name[8];
    uint16_t bytes_per_sector;
    uint8_t sectors_per_cluster;
    uint16_t reserved_sector_count;
    uint8_t table_count;
    uint16_t root_entry_count;
    uint16_t total_sectors_16;
    uint8_t media_type;
    uint16_t table_size_16;
    uint16_t sectors_per_track;
    uint16_t head_side_count;
    uint32_t hidden_sector_count;
    uint32_t total_sectors_32;

    /* This will be cast to it's specific type once the
    driver actually knows what type of FAT this is. */
    uint8_t extended_section[54];

} __attribute__((packed)) fat_bpb_t;

typedef struct {
    char filename[8];
    char extension[3];
    uint8_t attributes;
    uint8_t reserved;
    uint8_t create_time_tenth;
    uint16_t create_time;
    uint16_t create_date;
    uint16_t access_date;
    uint16_t first_cluster_hi;
    uint16_t modified_time;
    uint16_t modified_date;
    uint16_t first_cluster_lo;
    uint32_t size;
} __attribute__((__packed__)) fat_dir_ent_t;

/*
 * An array of FAT directory structure, with total size of a single sector.
 * Helps to use one block read and retrieve multiple entries.
 */
typedef fat_dir_ent_t fat_dir_list[SECT_SIZE / FAT_ROOTDIR_ENT_SIZE] __attribute__((aligned(16)));

typedef struct fat_metadata {
    uint32_t partition_lba;
    uint32_t total_sectors;
    uint32_t total_clusters;

    /* First sector of each region */
    uint32_t first_fat_sector;
    uint32_t first_rootdir_sector;
    uint32_t first_data_sector;

    /* Length of each region */
    uint32_t fat_sectors;
    uint32_t rootdir_sectors;
    uint32_t data_sectors;

    uint32_t size;

} fat_metadata_t;

void fat_init(uint32_t p_lba);

/**
 * @brief Finds the first cluster number of desired file
 *
 * @param full_filename should be formatted as stated in FAT spec. 8 bytes filename and 3 bytes
 * extension; all in uppercase.
 * @return int32_t positive number if file exits and has data; 0 if file is empty and -1 if not
 * found.
 */
int32_t fat_find_entry(const char *full_filename);
/**
 * @brief Load a cluster chain into destination
 *
 * @param clsno Entry cluster number
 * @param dst destination buffer
 * @param size_in_cluster size of buffer, should be a multiple of cluster size.
 * @return int8_t 0 on success -1 on error
 */
uint8_t fat_load_cls_chain(uint32_t clsno, void *dst, size_t size_in_cluster);
