#include "kernel.h"

#include "x86.h"

void __attribute__((cdecl)) _kmain(void) { halt(); }