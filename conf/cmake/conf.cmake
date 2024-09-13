# Debug stuff
set(CMAKE_VERBOSE_MAKEFILE n)

# Various useful locations
set(CONF_DIR    ${PROJECT_SOURCE_DIR}/conf/)
set(TOOLS_DIR   ${PROJECT_SOURCE_DIR}/tools/)
set(BUILD_DIR   ${CMAKE_BINARY_DIR}/)
set(CMAKE_DIR   ${CONF_DIR}/cmake/)
set(MISC_DIR    ${CONF_DIR}/misc/)
set(IMAGE_DIR   ${BUILD_DIR}/img/)

# Tools
set(DD      ${TOOLS_DIR}/dd)
set(DTOOLS  ${TOOLS_DIR}/disk-tools)

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
    COMMAND ${DD} --new ${HDD_DISK} 2097152
    COMMAND sfdisk -f ${HDD_DISK} < ${HDD_PARTITION_TABLE} > /dev/null
    COMMAND ${DTOOLS} --lo ${HDD_DISK}
	COMMAND sudo mkfs.fat -F 16 /dev/loop0p1 > /dev/null
	COMMAND sudo mkfs.fat -F 16 /dev/loop0p2 > /dev/null
	COMMAND sudo mkfs.fat -F 16 /dev/loop0p3 > /dev/null
	COMMAND sudo mkfs.fat -F 16 /dev/loop0p4 > /dev/null
    COMMAND ${DTOOLS} --dlo ${HDD_DISK}
    DEPENDS ${HDD_PARTITION_TABLE}
    COMMENT "Creating ${HDD_DISK}, may take some time..."
)

add_custom_target(
    ${FDA_IMG_NAME}
    COMMAND mkdir -p ${IMAGE_DIR}
    COMMAND ${DD} --new ${FDA_DISK} 2880
	COMMAND mkfs.fat -F 12 -n "MARIOS" ${FDA_DISK}  > /dev/null
    COMMENT "Creating ${FDA_DISK}, may take some time..."
)

