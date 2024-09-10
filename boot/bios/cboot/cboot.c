#include "fat.h"
#include "print.h"

uint8_t file_buff[FAT_CLUSTER_SIZE_IN_BYTES * 3];
void __attribute__((cdecl)) _main(uint32_t boot_partition_addr)
{
    clear_screen();
    puts("Welcome to CBoot!\n");
    puts("\nInitializing the system\n");

    /* Enable FAT driver */
    puts("Enabling FAT driver\n");
    fat_init(boot_partition_addr);

    uint32_t clsno = fat_find_entry("CBOOT   BIN");
    putc('0' + clsno);

    /* TODO fix load bug */
    if (fat_load_cls_chain(clsno, file_buff, 3) == FAT_SUCCESSFUL_LOAD)
        puts("file successfully loaded\n");

    return;
}
