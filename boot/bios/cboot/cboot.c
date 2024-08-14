#include "ata.h"
#include "print.h"

void __attribute__((cdecl)) _main(void)
{
    __asm__("cli");
    __asm__("hlt");
}
