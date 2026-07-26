# Target system
set(CMAKE_SYSTEM_NAME       Generic)
set(CMAKE_SYSTEM_PROCESSOR  i686)

# Without that flag CMake is not able to pass test compilation check
set(CMAKE_C_COMPILER_WORKS true)
set(CMAKE_CXX_COMPILER_WORKS true)
set(CMAKE_TRY_COMPILE_TARGET_TYPE "STATIC_LIBRARY")

#
# Toolchain
#
set(CMAKE_C_COMPILER        clang)
set(CMAKE_CXX_COMPILER      clang++)
set(CMAKE_ASM_COMPILER      nasm)

set(CMAKE_AR               llvm-ar)
set(CMAKE_RANLIB           llvm-ranlib)
set(CMAKE_OBJCOPY          llvm-objcopy)
set(CMAKE_SIZE             llvm-size)
set(CMAKE_STRIP            llvm-strip)
set(CMAKE_NM               llvm-nm)

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

set(CMAKE_EXPORT_COMPILE_COMMANDS on)