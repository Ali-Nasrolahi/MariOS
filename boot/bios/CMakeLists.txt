# Helper function for setting build options
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
    ## Headers
    cboot/x86.h

    ## Sources
    cboot/cboot.s
    cboot/cboot.c
    cboot/print.c
    cboot/ata.c
    cboot/fat.c
)

target_set_spec(cboot.elf32 cboot/)

add_custom_command(
    TARGET core mbr cboot.elf32 POST_BUILD
    COMMAND ${DD} --cp $<TARGET_FILE:mbr> ${HDD_DISK}     2> /dev/null
    COMMAND ${DD} --cp $<TARGET_FILE:core> ${HDD_DISK} 1  2> /dev/null
    COMMAND ${CMAKE_OBJCOPY} -O binary
    $<TARGET_FILE:cboot.elf32>
    $<TARGET_FILE_DIR:cboot.elf32>/cboot
	COMMAND ${DTOOLS} --lo ${HDD_DISK}
	COMMAND ${DTOOLS} --mnt ${HDD_DISK}
	COMMAND sudo cp $<TARGET_FILE_DIR:cboot.elf32>/cboot /mnt/loop0/p1/cboot.bin
	COMMAND ${DTOOLS} --umnt ${HDD_DISK}
	COMMAND ${DTOOLS} --dlo ${HDD_DISK}
    COMMENT "Copying bootloader to ${HDD_DISK}"
)
