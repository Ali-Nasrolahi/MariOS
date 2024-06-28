void boot_main(void)
{
    __asm__("cli");
    __asm__("hlt");
}