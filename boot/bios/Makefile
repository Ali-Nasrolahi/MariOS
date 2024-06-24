include ../../conf/make/config.mk

# TODO:
# 	- Create a target for 'ptable.bak'
#	- Clean up the partitioning and disk creation

OUTPUT_IMG = hdd.img

all: format-vdisk mbr core cboot
	@$(MAKE) mount
	@echo "Copying cboot to first partition of $(OUTPUT_IMG)"
	@sudo cp cboot.bin /mnt/loop0/p1/cboot.bin
	@$(MAKE) umount

fresh: clean all

################### BUILD ########################
mbr: mbr.s
	@$(ASM) -f bin $^ -o $@.bin
	truncate --size 446 $@.bin

	@echo "Copying $@ to $(OUTPUT_IMG)"
	@$(DD) --cp mbr.bin $(OUTPUT_IMG) 2> /dev/null
	@echo ""

core: core.s
	@$(ASM) -f bin $^ -o $@.bin
	@echo "Copying $@ to $(OUTPUT_IMG)"
	@$(DD) --cp $@.bin $(OUTPUT_IMG) 1 2> /dev/null
	@echo ""

cboot: cboot.s.o cboot.o
	$(LD) $(LDFLAGS) -T link.ld $^

%.s.o: %.s
	$(ASM) $(ASMFLAGS) $^ -o $@

%.o: %.c
	$(CC) $(CFLAGS) -c $< -o $@

################### FUNCTIONS ########################
create-floppy:
#	Standard Floppy disk size is 1.44 mb which is 2880 sectors of 512 bytes
	@echo "Create a virtual floppy disk"
	@$(DD) --new $(OUTPUT_IMG) 2880 2> /dev/null

	@echo "Format the disk with FAT12"
	@mkfs.fat -F 12 -n "MARIOS" $(OUTPUT_IMG) > /dev/null

create-vdisk: $(OUTPUT_IMG) ptable.bak
	@echo "Partitioning the HDD based on ptable.bak"
	@sfdisk -f $(OUTPUT_IMG) < ptable.bak > /dev/null

$(OUTPUT_IMG):
	@echo "Creating 1GB RAW virtual disk: $@ (might take some time....)"
	@$(DD) --new $@ 2097152 2> /dev/null

format-vdisk: create-vdisk
	@echo "Formatting $(OUTPUT_IMG) with FAT16"
	@echo "Create loopback device"
	@$(DTOOLS) --lo
	@echo "Formatting partitions"
	@sudo mkfs.fat -F 16 /dev/loop0p1 > /dev/null
	@sudo mkfs.fat -F 16 /dev/loop0p2 > /dev/null
	@sudo mkfs.fat -F 16 /dev/loop0p3 > /dev/null
	@sudo mkfs.fat -F 16 /dev/loop0p4 > /dev/null
	@echo "Delete loopback"
	@$(DTOOLS) --dlo

mount:
	@$(DTOOLS) --lo
	@$(DTOOLS) --mnt
	@echo "Disk Mounted"

umount:
	@$(DTOOLS) --umnt
	@$(DTOOLS) --dlo
	@echo "Disk Umounted"

run: all
	$(QEMU) -hda $(OUTPUT_IMG)

debug: all
	$(QEMU) -S -s -hda $(OUTPUT_IMG) &
	$(GDB) -ex "connect-to-qemu"

clean:
	$(RM) *.bin *.o *.lst *.img *.map

.PHONY: all clean run debug