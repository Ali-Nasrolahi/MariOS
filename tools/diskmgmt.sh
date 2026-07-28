#!/usr/bin/env bash
set -euo pipefail

LOOP_DEV="${LOOP_DEV:-loop1000}"
IMAGE="${2:-hdd.img}"

usage() {
    cat <<EOF
Usage:
    $(basename "$0") <command> [arguments]

Image operations
    new <image> <count>            Create image (count * 512 bytes)
    copy <from> <to> [seek]        Copy into image (conv=notrunc)

Loop device operations
    attach [image]                 Attach image to /dev/${LOOP_DEV}
    detach                         Detach /dev/${LOOP_DEV}
    mount                          Mount p1-p4 under /mnt/${LOOP_DEV}
    umount                         Unmount p1-p4

Legacy aliases
    --new
    --cp
    --lo
    --dlo
    --mnt
    --umnt
EOF
}

attach() {
    sudo losetup -d "/dev/${LOOP_DEV}" 2>/dev/null || true
    sudo losetup -P "/dev/${LOOP_DEV}" "$IMAGE"
}

detach() {
    sudo losetup -d "/dev/${LOOP_DEV}"
}

mount_partitions() {
    for p in {1..4}; do
        sudo mkdir -p "/mnt/${LOOP_DEV}/p${p}"
        sudo mount "/dev/${LOOP_DEV}p${p}" "/mnt/${LOOP_DEV}/p${p}"
    done
}

umount_partitions() {
    for p in 4 3 2 1; do
        sudo umount "/dev/${LOOP_DEV}p${p}"
    done

    for p in {1..4}; do
        sudo rmdir "/mnt/${LOOP_DEV}/p${p}"
    done

    sudo rmdir "/mnt/${LOOP_DEV}"
}

new_image() {
    dd if=/dev/zero of="$2" bs=512 count="$3"
}

copy_image() {
    local seek="${4:-0}"
    dd if="$2" of="$3" seek="$seek" conv=notrunc
}

[[ $# -ge 1 ]] || {
    usage
    exit 1
}

case "$1" in
new | --new)
    [[ $# -ge 3 ]] || usage
    new_image "$@"
    ;;
copy | --cp)
    [[ $# -ge 3 ]] || usage
    copy_image "$@"
    ;;
attach | --lo)
    attach
    ;;
detach | --dlo)
    detach
    ;;
mount | --mnt)
    mount_partitions
    ;;
umount | --umnt)
    umount_partitions
    ;;
*)
    usage
    exit 1
    ;;
esac
