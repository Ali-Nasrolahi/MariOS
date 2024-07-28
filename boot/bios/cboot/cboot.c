void _test(void)
{
    __asm__("cli");
    __asm__("hlt");
}
void __attribute__((cdecl)) _main(void) { _test(); }
