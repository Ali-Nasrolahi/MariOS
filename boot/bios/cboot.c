void boot_main(void)
{
    __asm__ volatile(".global _start");
    __asm__ volatile("_start:");
}