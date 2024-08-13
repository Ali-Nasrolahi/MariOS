# TODO:
# 	- Create a target for 'ptable.bak'
#	- Clean up the partitioning and disk creation
TOP 		:= $(dir $(lastword $(MAKEFILE_LIST)))
QEMU		?= qemu-system-x86_64
GDB			?= gdb
OUTPUT_IMG 	:= hdd.img
DD 			:= $(TOP)/../../tools/dd
DTOOLS 		:= $(TOP)/../../tools/disk-tools


all: config build

config:
	cmake -B build -D CMAKE_BUILD_TYPE=Debug
	@echo -e  "Config Completed\n"

build:
	cmake --build build -j8
	@echo -e  "Build Completed\n"

build_the_img:
	cmake --build build --target $(OUTPUT_IMG)

fresh: distclean config build_the_img build

clean:
	cmake --build build --target clean || true

distclean: clean
	$(RM) -r build/* *.img

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

.PHONY: all config build clean
