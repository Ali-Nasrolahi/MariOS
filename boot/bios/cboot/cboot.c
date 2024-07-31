#include "drivers.h"

void __attribute__((cdecl)) _main(void)
{
    puts("12341\t121212\t121212\n");
    puts("12341\t121212\t121212\n");
    __asm__("cli");
    __asm__("hlt");
}
