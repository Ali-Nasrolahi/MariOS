include ../conf/make/config.mk

C_SOURCES= 	$(wildcard *.c)
HEADERS= 	$(wildcard *.h)

# Nice syntax for file extension replacement
OBJ= ${C_SOURCES:.c=.o}

all: kernel.bin

kernel.bin: kernel.o $(OBJ)
	$(LD) $(LDFLAGS) -Map kernel.map -o $@ -T kernel.ld $^

kernel.elf: kernel_entry.o $(OBJ)
	$(LD) --oformat elf32-i386 $(LDFLAGS) -o $@ -T kernel.ld $^

%.o: %.c $(HEADERS)
	$(CC) $(CFLAGS) -c $< -o $@

.debug: kernel.elf os.bin
	$(QEMU) -S -s -fda os.bin &
	$(GDB) -ex "target remote localhost:1234" \
	-ex "symbol-file kernel.elf" \
	-ex "break kmain"

clean:
	find -type f -name "*.o" -delete
	find -type f -name "*.bin" -delete
	find -type f -name "*.elf" -delete
