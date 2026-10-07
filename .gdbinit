set debuginfod enabled on
define debug-marios
set confirm off
file build/boot/cboot.elf32
target remote localhost:1234
set disassembly-flavor intel
layout src
layout split
break _main
continue
set confirm on
end
