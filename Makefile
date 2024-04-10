# $@ = target file
# $< = first dependency
# $^ = all dependencies
C_SOURCES= 	$(wildcard kernel/*.c driver/*.c)
HEADERS= 	$(wildcard kernel/*.h driver/*.h)
# Nice syntax for file extension replacement
OBJ= ${C_SOURCES:.c=.o}

# Change this if your cross-compiler is somewhere else
AS=  nasm
CC=  i686-elf-gcc
LD=  i686-elf-ld
GDB= gdb
QMU= qemu-system-x86_64

CFLAGS= 	-g -O0 -Wall -Wextra -ffreestanding -std=gnu99 -lgcc
CXXFLAGS= 	-g -ffreestanding -O2 -Wall -Wextra -fno-exceptions -fno-rtti
LDFLAGS= 	-nostdlib

KERNEL_DIR= kernel
BOOT_DIR= 	boot/bios

all: os.bin

os.bin: boot.bin kernel.bin
	cat $^ > os.bin

boot.bin: $(BOOT_DIR)/boot.s
	$(AS) -g -f bin $^ -o $@

kernel.bin: kernel_entry.o $(OBJ)
	$(LD) $(LDFLAGS) -Map kernel.map -o $@ -T $(KERNEL_DIR)/kernel.ld $^

kernel.elf: kernel_entry.o $(OBJ)
	$(LD) --oformat elf32-i386 $(LDFLAGS) -o $@ -T $(KERNEL_DIR)/kernel.ld $^

kernel_entry.o: $(KERNEL_DIR)/kernel_entry.s
	$(AS) -f elf $^ -o $@

%.o: %.c $(HEADERS)
	$(CC) $(CFLAGS) -c $< -o $@

run: os.bin
	$(QMU) -fda os.bin

debug: kernel.elf os.bin
	$(QMU) -S -s -fda os.bin &
	$(GDB) -ex "target remote localhost:1234" \
	-ex "symbol-file kernel.elf" \
	-ex "break kmain"

disassemble:
	ndisasm os.bin

clean:
	find -type f -name "*.o" -delete
	find -type f -name "*.bin" -delete
	find -type f -name "*.elf" -delete
