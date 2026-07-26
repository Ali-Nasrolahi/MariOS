#include "fat.h"
#include "print.h"

void* buff = (void*)0x00100000;
void __attribute__((cdecl)) _main(uint32_t boot_partition_addr)
{
    /* Welcome */
    clear_screen();
    puts("Welcome to CBoot!\n");
    puts("\nInitializing the system\n");

    /* Enable FAT driver */
    puts("Enabling FAT driver\n");
    fat_init(boot_partition_addr);

    /* Load the kernel */
    if (fat_load_cls_chain(fat_find_entry("KERNEL  IMG"), buff, 10) == FAT_SUCCESSFUL_LOAD) {
        puts("Kernel loaded successfully\n");
    } else {
        puts("Kernel loading failed!!!\n");
    }

    return;
}
