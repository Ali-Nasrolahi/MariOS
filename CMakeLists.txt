cmake_minimum_required(VERSION 3.30)

# Toolchain Configurations
set(CMAKE_TOOLCHAIN_FILE ${CMAKE_CURRENT_SOURCE_DIR}/conf/cmake/toolchain.cmake)

project(MariOS ASM_NASM C CXX)

include(conf/cmake/conf.cmake)

# Bootloader
add_subdirectory(boot/bios)

# Kernel
add_subdirectory(kernel)

