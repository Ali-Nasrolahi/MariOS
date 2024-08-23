set(CMAKE_SYSTEM_NAME       Generic)
set(CMAKE_SYSTEM_PROCESSOR  i686)
set(TARGET_BIN_DIR          $ENV{TARGET_BIN_DIR})
set(TARGET                  ${TARGET_BIN_DIR}/$ENV{TARGET})

# Without that flag CMake is not able to pass test compilation check
#   .Alt:  set(CMAKE_C_COMPILER_WORKS true)
set(CMAKE_TRY_COMPILE_TARGET_TYPE "STATIC_LIBRARY")

set(CMAKE_AR            ${TARGET}-ar)
set(CMAKE_ASM_COMPILER  nasm)
set(CMAKE_C_COMPILER    ${TARGET}-gcc)
set(CMAKE_CXX_COMPILER  ${TARGET}-g++)
set(CMAKE_LINKER        ${TARGET}-ld)
set(CMAKE_OBJCOPY       ${TARGET}-objcopy)
set(CMAKE_RANLIB        ${TARGET}-ranlib)
set(CMAKE_SIZE          ${TARGET}-size)
set(CMAKE_STRIP         ${TARGET}-strip)

set(CMAKE_ASM_NASM_SOURCE_FILE_EXTENSIONS ${CMAKE_ASM_NASM_SOURCE_FILE_EXTENSIONS} s S)

# Telling cmake how linking should be
set(CMAKE_ASM_NASM_LINK_EXECUTABLE
    "<CMAKE_LINKER> <CMAKE_ASM_NASM_LINK_FLAGS> <LINK_FLAGS> <OBJECTS>  -o <TARGET> <LINK_LIBRARIES>"
)
set(CMAKE_C_LINK_EXECUTABLE
    "<CMAKE_LINKER> <CMAKE_C_LINK_FLAGS> <LINK_FLAGS> <OBJECTS>  -o <TARGET> <LINK_LIBRARIES>"
)
set(CMAKE_CXX_LINK_EXECUTABLE
    "<CMAKE_LINKER> <CMAKE_CXX_LINK_FLAGS> <LINK_FLAGS> <OBJECTS>  -o <TARGET> <LINK_LIBRARIES>"
)


# Compile and Linking flags
set(compile_opts
    $<$<CONFIG:Debug>:-g -O0>
    $<$<COMPILE_LANGUAGE:ASM_NASM>:-f elf>
    $<$<COMPILE_LANGUAGE:C,CXX>:-ggdb -Wall -Wextra -pedantic -ffreestanding -masm=intel -lgcc>
    $<$<COMPILE_LANGUAGE:C>:-std=gnu99>
    $<$<COMPILE_LANGUAGE:CXX>:-fno-exceptions -fno-rtti>
)

set(link_opts
    -nostdlib
    $<$<COMPILE_LANGUAGE:ASM_NASM>:>
    $<$<COMPILE_LANGUAGE:C,CXX>:>
)

add_compile_options("${compile_opts}")
add_link_options("${link_opts}")
