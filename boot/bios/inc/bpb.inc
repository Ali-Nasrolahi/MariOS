bits 16

bpb_base:
; BPB (BIOS Parameter Block)
jmp short _start                            ; The first three bytes EB 3C 90 disassemble to JMP SHORT 3C NOP.
nop
bpb_oem                 db 'MSWIN4.1'       ; OEM identifier.
bpb_bytes_per_sect      dw 0x0000           ; The number of Bytes per sector (remember, all numbers are in the little-endian format).
bpb_sect_per_clust      db 0x00             ; Number of sectors per cluster.
bpb_resv_sect           dw 0x0000 	        ; Number of reserved sectors. The boot record sectors are included in this value.
bpb_no_fat              db 0x00             ; Number of File Allocation Tables (FAT's) on the storage media. Often this value is 2.
bpb_root_ent            dw 0x0000           ; Number of root directory entries (must be set so that the root directory occupies entire sectors).

bpb_total_sect          dw 0x0000           ; The total sectors in the logical volume. If this value is 0,
                                            ; it means there are more than 65535 sectors in the volume,
                                            ; and the actual count is stored in the Large Sector Count entry at 0x20.

bpb_media               db 0x00             ; (offset 21, addr: 0x15) This Byte indicates the media descriptor type
bpb_sect_per_fat        dw 0x0000           ; Number of sectors per FAT. FAT12/FAT16 only.
bpb_sect_per_track      dw 0x0000           ; Number of sectors per track.
bpb_head_per_cyld       dw 0x0000           ; Number of heads or sides on the storage media.
bpb_hid_sect            dd 0x000000000      ; Number of hidden sectors. (i.e. the LBA of the beginning of the partition.)

bpb_total_sect_large    dd 0x000000000      ; Large sector count. This field is set if there are more than 65535 sectors in the volume,
                                            ; resulting in a value which does not fit in the Number of Sectors entry at 0x13.

bpb_drive_no            db 0x00             ; Drive number. The value here should be identical to the value returned by BIOS interrupt 0x13,
                                            ; or passed in the DL register; i.e. 0x00 for a floppy disk and 0x80 for hard disks.
                                            ; This number is useless because the media
                                            ; is likely to be moved to another machine and inserted in a drive with a different drive number.

bpp_nt_fl               db 0x00             ; Flags in Windows NT. Reserved otherwise.
bpp_boot_sig            db 0x00             ; Signature (must be 0x28 or 0x29).
bpp_serial_no           dd 0x000000000      ; VolumeID 'Serial' number. Used for tracking volumes between computers. You can ignore this if you want.
bpp_vl_label            db 'MARIO_OS_LB'    ; Volume label string. This field is padded with spaces.
bpp_fs                  db 'FAT16   '       ; System identifier string. This field is a string representation of
                                            ; the FAT file system type. It is padded with spaces.
                                            ; The spec says never to trust the contents of this string for any use.
