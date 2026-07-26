cmake_minimum_required(VERSION 3.30)

# Toolchain Configurations
set(CMAKE_TOOLCHAIN_FILE ${CMAKE_CURRENT_SOURCE_DIR}/cmake/toolchain.cmake)

project(MariOS ASM_NASM C CXX)

include(cmake/conf.cmake)

# Bootloader
add_subdirectory(boot)

# Kernel
add_subdirectory(kernel)

