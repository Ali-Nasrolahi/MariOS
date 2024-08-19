cmake_minimum_required(VERSION 3.20)

set(CMAKE_TOOLCHAIN_FILE ../../conf/cmake/toolchain.cmake)

project(core ASM_NASM C CXX)

set(CMAKE_VERBOSE_MAKEFILE n)

# Tools
set(HDD_DISK hdd.img)
set(FDA_DISK floppy.img)

set(DD ../../tools/dd)
set(DTOOLS ../../tools/disk-tools)

function(target_set_spec tgt dir)
    target_compile_options(
        ${tgt}
        PRIVATE
        $<$<COMPILE_LANGUAGE:ASM_NASM>:-I${CMAKE_CURRENT_SOURCE_DIR}/asm/inc>
    )
    set_target_properties(${tgt}
        PROPERTIES LINK_DEPENDS
        ${CMAKE_CURRENT_SOURCE_DIR}/${dir}/${tgt}.ld
    )

    target_link_options(${tgt}
        PRIVATE
        -T ${CMAKE_CURRENT_SOURCE_DIR}/${dir}/${tgt}.ld
        -Map=${tgt}.map
    )
endfunction()

# MBR
add_executable(mbr core/mbr.s)
target_set_spec(mbr core/)

# Core
add_executable(core core/core.s)
target_set_spec(core core/)

# CBoot
add_executable(cboot.elf32

    cboot/x86.h

    cboot/cboot.s
    cboot/cboot.c
    cboot/print.c
    cboot/ata.c
    cboot/fat.c
)

target_set_spec(cboot.elf32 cboot/)


# Post Build
add_custom_target(
    ${HDD_DISK}
    COMMAND ${DD} --new ${HDD_DISK} 2097152
    COMMAND sfdisk -f ${HDD_DISK} < misc/ptable.bak > /dev/null
    COMMAND ${DTOOLS} --lo
	COMMAND sudo mkfs.fat -F 16 /dev/loop0p1 > /dev/null
	COMMAND sudo mkfs.fat -F 16 /dev/loop0p2 > /dev/null
	COMMAND sudo mkfs.fat -F 16 /dev/loop0p3 > /dev/null
	COMMAND sudo mkfs.fat -F 16 /dev/loop0p4 > /dev/null
    COMMAND ${DTOOLS} --dlo
    DEPENDS misc/ptable.bak
    WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
    COMMENT "Creating ${HDD_DISK}, may take some time..."
)

add_custom_target(
    ${FDA_DISK}
    COMMAND ${DD} --new ${FDA_DISK} 2880
	COMMAND mkfs.fat -F 12 -n "MARIOS" ${FDA_DISK}  > /dev/null
    WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
    COMMENT "Creating ${FDA_DISK}, may take some time..."
)

add_custom_command(
    TARGET core mbr cboot.elf32 POST_BUILD
    COMMAND ${DD} --cp $<TARGET_FILE:mbr> ${HDD_DISK}     2> /dev/null
    COMMAND ${DD} --cp $<TARGET_FILE:core> ${HDD_DISK} 1  2> /dev/null
    COMMAND ${CMAKE_OBJCOPY} -O binary
    $<TARGET_FILE:cboot.elf32>
    $<TARGET_FILE_DIR:cboot.elf32>/cboot
	COMMAND ${DTOOLS} --lo
	COMMAND ${DTOOLS} --mnt
	COMMAND sudo cp $<TARGET_FILE_DIR:cboot.elf32>/cboot /mnt/loop0/p1/cboot.bin
	COMMAND ${DTOOLS} --umnt
	COMMAND ${DTOOLS} --dlo
    WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
    COMMENT "Writing bootloader to ${HDD_DISK}"
)
