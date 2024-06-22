all: boot

boot:
	make -C boot/bios

kernel:
	make -C kernel

clean:
	make -C boot/bios clean
	make -C kernel clean

.PHONY: all clean boot kernel