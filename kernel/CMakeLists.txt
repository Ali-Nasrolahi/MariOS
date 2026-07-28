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
	COMMAND ${DISK_MGMT} --lo ${HDD_DISK}
	COMMAND ${DISK_MGMT} --mnt ${HDD_DISK}
	COMMAND sudo cp $<TARGET_FILE:kernel> /mnt/${LOOP_DEV}/p1/kernel.img
	COMMAND ${DISK_MGMT} --umnt ${HDD_DISK}
	COMMAND ${DISK_MGMT} --dlo ${HDD_DISK}
    COMMENT "Copying kernel to ${HDD_DISK}"
)

# To prevent post-build race conditions
add_dependencies(kernel cboot.elf32)
