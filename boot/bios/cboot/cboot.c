#include "fat.h"
#include "print.h"

void __attribute__((cdecl)) _main(void)
{
    clear_screen();
    puts("Welcome to CBoot!\n");
    puts("\nInitializing the system\n");

    /* Enable FAT driver */
    puts("Enabling FAT driver\n");
    fat_init();
    __asm__("cli");
    __asm__("hlt");
}
