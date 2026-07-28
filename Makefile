# TODO:
# 	- Create a target for 'ptable.bak'
#	- Clean up the partitioning and disk creation
QEMU		?= qemu-kvm
GDB			?= gdb
OUTPUT_IMG	:= build/img/hdd.img
IMG_TARGET	:= hdd.img
DISK_MGMT		:= ./tools/diskmgmt.sh


all: config build

config:
	cmake --preset debug
	@echo -e  "Config Completed\n"

build:
	cmake --build build -j8
	@echo -e  "Build Completed\n"

build_the_img:
	cmake --build build --target $(IMG_TARGET)

fresh: distclean config build_the_img build

clean:
	cmake --build build --target clean || true

distclean: clean
	$(RM) -r build/*

mount:
	@$(DISK_MGMT) --lo ${OUTPUT_IMG}
	@$(DISK_MGMT) --mnt ${OUTPUT_IMG}
	@echo "Disk Mounted"

umount:
	@$(DISK_MGMT) --umnt ${OUTPUT_IMG}
	@$(DISK_MGMT) --dlo ${OUTPUT_IMG}
	@echo "Disk Umounted"

run: all
	$(QEMU) -hda $(OUTPUT_IMG)

debug: all
	$(QEMU) -S -s -hda $(OUTPUT_IMG) &
	$(GDB) \
		-ex "set confirm off" \
		-ex "connect-to-qemu" \
		-ex "add-symbol-file build/boot/bios/cboot.elf32" \
		-ex "break _main" \
		-ex "continue" \
		-ex "set confirm on"

.PHONY: all config build clean
