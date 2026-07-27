set(CMAKE_ASM_NASM_LINK_EXECUTABLE
    "<CMAKE_LINKER> <CMAKE_ASM_NASM_LINK_FLAGS> <LINK_FLAGS> <OBJECTS>  -o <TARGET> <LINK_LIBRARIES>"
)
set(CMAKE_C_LINK_EXECUTABLE
    "<CMAKE_LINKER> <CMAKE_C_LINK_FLAGS> <LINK_FLAGS> <OBJECTS>  -o <TARGET> <LINK_LIBRARIES>"
)
set(CMAKE_CXX_LINK_EXECUTABLE
    "<CMAKE_LINKER> <CMAKE_CXX_LINK_FLAGS> <LINK_FLAGS> <OBJECTS>  -o <TARGET> <LINK_LIBRARIES>"
)

set(CMAKE_ASM_NASM_SOURCE_FILE_EXTENSIONS ${CMAKE_ASM_NASM_SOURCE_FILE_EXTENSIONS} s S)

# Compile and Linking flags
set(compile_opts
    $<$<CONFIG:Debug>:-g -O0>
    $<$<COMPILE_LANGUAGE:ASM_NASM>:-f elf>
    $<$<COMPILE_LANGUAGE:C,CXX>:-ggdb -Wall -Wextra -pedantic -ffreestanding -masm=intel --target=i686-unknown-elf>
    $<$<COMPILE_LANGUAGE:C>:-std=gnu99>
    $<$<COMPILE_LANGUAGE:CXX>:-fno-exceptions -fno-rtti>
)

set(link_opts
    -nostdlib
    -melf_i386
    $<$<COMPILE_LANGUAGE:ASM_NASM>:>
    $<$<COMPILE_LANGUAGE:C,CXX>:>
)

add_compile_options("${compile_opts}")
add_link_options("${link_opts}")