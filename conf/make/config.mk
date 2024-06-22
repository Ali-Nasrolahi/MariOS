
TOP := $(dir $(lastword $(MAKEFILE_LIST)))

###########################
# Toolchain configuration #
###########################
ASM			= nasm
CC			= i686-elf-gcc
LD			= i686-elf-ld

ASMFLAGS 	?= -g -f elf -l $(basename $@).lst
CFLAGS		?= -g -O0 -Wall -Wextra -ffreestanding -std=gnu99 -lgcc -masm=intel
CXXFLAGS	?= -g -ffreestanding -O2 -Wall -Wextra -fno-exceptions -fno-rtti
LDFLAGS		?= -M=$@.map -nostdlib

QEMU 		?= qemu-system-x86_64
GDB 		?= gdb

##########
# Others #
##########


DD := $(TOP)/../../tools/dd
DTOOLS := $(TOP)/../../tools/disk-tools
