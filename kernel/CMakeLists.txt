# Kernel
add_executable(
    kernel # Target

    ## Headers
    kernel.h

    ## Sources
    kernel.c
)

target_link_options(kernel PRIVATE -T${CMAKE_CURRENT_SOURCE_DIR}/kernel.ld -Map=kernel.map)

add_custom_command(
    TARGET kernel POST_BUILD
	COMMAND ${DTOOLS} --lo ${HDD_DISK}
	COMMAND ${DTOOLS} --mnt ${HDD_DISK}
	COMMAND sudo cp $<TARGET_FILE:kernel> /mnt/loop0/p1/kernel.img
	COMMAND ${DTOOLS} --umnt ${HDD_DISK}
	COMMAND ${DTOOLS} --dlo ${HDD_DISK}
    COMMENT "Copying kernel to ${HDD_DISK}"
)

# To prevent post-build race conditions
add_dependencies(kernel cboot.elf32)
