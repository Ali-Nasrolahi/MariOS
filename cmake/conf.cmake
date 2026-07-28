# Debug stuff
set(CMAKE_VERBOSE_MAKEFILE n)

# Various useful locations
set(TOOLS_DIR   ${PROJECT_SOURCE_DIR}/tools)
set(BUILD_DIR   ${CMAKE_BINARY_DIR})
set(CMAKE_DIR   ${PROJECT_SOURCE_DIR}/cmake)
set(MISC_DIR    ${PROJECT_SOURCE_DIR}/misc)
set(IMAGE_DIR   ${BUILD_DIR}/img)

set(DISK_MGMT  ${TOOLS_DIR}/diskmgmt.sh)

# Output images
set(HDD_IMG_NAME    hdd.img)
set(FDA_IMG_NAME    floppy.img)
set(HDD_DISK        ${IMAGE_DIR}/${HDD_IMG_NAME})
set(FDA_DISK        ${IMAGE_DIR}/${FDA_IMG_NAME})

# Images custom configs
set(HDD_PARTITION_TABLE ${MISC_DIR}/ptable.bak)

## Custom targets for building images
add_custom_target(
    ${HDD_IMG_NAME}
    COMMAND mkdir -p ${IMAGE_DIR}
    COMMAND ${DISK_MGMT} --new ${HDD_DISK} 2097152
    COMMAND sfdisk -f ${HDD_DISK} < ${HDD_PARTITION_TABLE} > /dev/null
    COMMAND ${DISK_MGMT} --lo ${HDD_DISK}
	COMMAND sudo mkfs.fat -F 16 /dev/${LOOP_DEV}p1 > /dev/null
	COMMAND sudo mkfs.fat -F 16 /dev/${LOOP_DEV}p2 > /dev/null
	COMMAND sudo mkfs.fat -F 16 /dev/${LOOP_DEV}p3 > /dev/null
	COMMAND sudo mkfs.fat -F 16 /dev/${LOOP_DEV}p4 > /dev/null
    COMMAND ${DISK_MGMT} --dlo ${HDD_DISK}
    DEPENDS ${HDD_PARTITION_TABLE}
    COMMENT "Creating ${HDD_DISK}, may take some time..."
)

add_custom_target(
    ${FDA_IMG_NAME}
    COMMAND mkdir -p ${IMAGE_DIR}
    COMMAND ${DISK_MGMT} --new ${FDA_DISK} 2880
	COMMAND mkfs.fat -F 12 -n "MARIOS" ${FDA_DISK}  > /dev/null
    COMMENT "Creating ${FDA_DISK}, may take some time..."
)

