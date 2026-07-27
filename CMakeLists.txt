cmake_minimum_required(VERSION 3.30)

project(MariOS ASM_NASM C CXX)

include(cmake/conf.cmake)

# Bootloader
add_subdirectory(boot)

# Kernel
add_subdirectory(kernel)

