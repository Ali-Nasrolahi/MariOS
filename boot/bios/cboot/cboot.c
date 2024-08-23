#include "fat.h"
#include "print.h"

void __attribute__((cdecl)) _main(uint32_t boot_partition_addr)
{
    clear_screen();
    puts("Welcome to CBoot!\n");
    puts("\nInitializing the system\n");

    /* Enable FAT driver */
    puts("Enabling FAT driver\n");
    fat_init(boot_partition_addr);
    fat_print_files();

    return;
}
