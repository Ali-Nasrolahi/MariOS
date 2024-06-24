bits 16
;
; Limited FAT tools
; Note:
; Following routines use FAT_* parameters for their calculations.
; So make sure they're set correctly. and call 'fat_init' for
; before using any routine.

; Constants
FAT_ENT_EOF     equ 0xfff8  ; (>=) 0xFFF8 then there are no more clusters in the chain.
FAT_BASE_ADDR   equ 0x7e00  ; This address is used as base address for loading FS various metadatas
                            ; Metadata means Rootdir, FAT Table and etc which will be overwritten
                            ; multiple times with needed metadata at the time.

; Initilizes necessary fields for other routines.
; Params:
;   bx[in] = selected partition address
;
fat_init:
.load_partition_table:
    ; NOTE:
    ;   Further FAT calculation is based on first secotr of
    ;   selected volume, however LBA uses absoulte address of
    ;   our hard disk not the selected volume.
    ;   Therefore, we need to add volume offset to further calculations.
    ;   To make it a little bit easier, let's just save the offset in
    ;   VOL_BEGIN_SECT which will be used like:
    ;       VOL_BEGIN_SECT + (whatever sector we need)
    mov eax, [bx + 8]
    mov [VOL_BEGIN_SECT], eax
    mov bx, FAT_BASE_ADDR
    mov cx, 1
    mov dl, [bpb_drive_no]
    call disk_hdd_lba_read

.set_bpb:
    ; Copy first 32 bytes (BPB) to `bpb_base`
    mov si, FAT_BASE_ADDR
    mov di, bpb_base
    mov cx, 9
    rep movsd

    mov ax, [bpb_sect_per_clust]
    shl ax, 9
    mov [FAT_CLS_SIZE_IN_BYTES], ax

.set_regions_sectors:

    ; 1. FAT Table
    mov ax, [bpb_resv_sect]
    mov [FAT_RGN_FAT], ax

    ; 2. Root Dir region
    xor ax, ax
    mov al, [bpb_no_fat]
    mul word [bpb_sect_per_fat]
    add ax, [bpb_resv_sect]
    mov [FAT_RGN_ROOT], ax

    ; 3. Data region
    ; Data region = (rootdir sect no.) + (rootdir len)
    call fat_determine_rootdir_len
    mov ax, [FAT_RGN_ROOT]
    add ax, [FAT_ROOTDIR_LEN]
    mov [FAT_RGN_DATA], ax

.end_fat_init:

    ret

; Calculates rootdir length.
; Params:
;   No parameter.
; Impl:
;   rootdir_len   =   ((bpb_root_ent * 32) + (512 - 1)) / 512
fat_determine_rootdir_len:

    push ax

    mov ax, [bpb_root_ent]
    shl ax, 5
    add ax, (512-1)
    shr ax, 9
    mov [FAT_ROOTDIR_LEN], ax

    pop ax
    ret

; Load Root Directory
; Params:
;   No parameter.
;
; Impl:
;     Root dir starts at: (Reserved Region + FAT Region)
;     How big is root_dir?
;     To determine the count of sectors occupied by the root directory
;     (Microsoft FAT Specification, chapter 3.5)
;     RootDirSectors = ((BPB_RootEntCnt * 32) + (BPB_BytsPerSec – 1)) / BPB_BytsPerSec
;
;     Results in:
;
;     rootdir_sect_no   = (bpb_resv_sect + bpb_no_fat * bpb_sect_per_fat);
;     rootdir_len       = ((bpb_root_ent * 32) + (512 - 1)) / 512
fat_load_rootdir:

    ; Read 'rootdir_len' sectors from 'rootdir_sect_no' to 0:FAT_BASE_ADDR
    mov eax, [VOL_BEGIN_SECT]
    add ax, [FAT_RGN_ROOT]
    mov bx, FAT_BASE_ADDR
    mov cx, [FAT_ROOTDIR_LEN]
    mov dl, [bpb_drive_no]
    call disk_hdd_lba_read

    ret

; Finds cls number of a file
; based on loaded rootdir at FAT_BASE_ADDR.
; So make sure to load fat table first.
;
; Params:
;     si[in]    : pointer to file name
;     di[out]   : Low bytes of cluster number
;     CF        : error indication (set on failure)
;
fat_find_file:

    push bp
    push si
    mov bp, sp
    mov di, FAT_BASE_ADDR
    clc ; Error indication

.begin:
    mov si ,[bp]
    mov cx, 11
    cmp byte [di], 0x0
    je .fail
    push di
    repe cmpsb
    pop di
    je .end
    add di, 32
    dec dx
    jnz .begin

.fail:
    mov si, FAT_FILE_NOT_FOUND
    call print
    mov si, [bp]
    call print
    call print_crlf
    stc ; Indicates error

.end:
    mov di, [di + 26] ; Cluster number of found entry
    pop si
    pop bp
    ret

; Loads FAT Table into FAT_BASE_ADDR
; Params:
;   No parameter.
; TODO:
;   Currently, my LBA read limited by BIOS's
;   maximum transferable sectors which is 0x80.
fat_load_table:

    jmp short .work_around

    ; FIXME
    ;   Handle bpb_sect_per_fat > 0x80
    mov eax, [VOL_BEGIN_SECT]
    add ax, [FAT_RGN_FAT]
    mov bx, FAT_BASE_ADDR
    mov cx, (0x100 - 0x80)
    mov dl, [bpb_drive_no]
    call disk_hdd_lba_read

; REMOVE WHEN FIXME IS DONE!
.work_around:
    mov eax, [VOL_BEGIN_SECT]
    add ax, [FAT_RGN_FAT]
    mov bx, FAT_BASE_ADDR
    mov cx, (0x100 - 0x80)
    mov dl, [bpb_drive_no]
    call disk_hdd_lba_read

    add ax, 0x20
    mov bx, (FAT_BASE_ADDR + 0x20 * 512)
    mov cx, 0x80
    mov dl, [bpb_drive_no]
    call disk_hdd_lba_read

    ret


; Finds a cluster's first sector
; Params:
;       eax[in/out] : Cluster no. (input, ax), sector number (output, eax)
; Impl:
;       first_sector_of_cluster = ((cls- 2) * bpb_sect_per_clust) + FAT_RGN_DATA
fat_cls_to_sect_no:
    dec ax
    dec ax
    mul byte [bpb_sect_per_clust]
    add ax, word [FAT_RGN_DATA]
    ret

; Loads a cluster into memory
; Params:
;   ax[in] : Cluster no.
;   bx[in] : Loads cluster's sector into this address
fat_load_cls:
    call fat_cls_to_sect_no

    add ax, [VOL_BEGIN_SECT]
    mov cl, byte [bpb_sect_per_clust]
    mov dl, [bpb_drive_no]
    call disk_hdd_lba_read
    ret

; Loads cluster chain
; Params:
;   ax[in] : First cluster no.
;   bx[in] : Output buffer address
fat_load_cls_chain:
    push bp
    push ax

    mov bp, sp

.load_cls:


    call fat_load_cls

    mov si, [bp]
    shl si, 1
    add si, FAT_BASE_ADDR

    mov ax, [si]
    mov [bp], ax
    add bx, [FAT_CLS_SIZE_IN_BYTES]
    cmp word [si], FAT_ENT_EOF
    jb .load_cls

.eof:
    pop ax
    pop bp
    ret

VOL_BEGIN_SECT  dd 0

; Regions sector no.
; WARNING:
;   Regions are 'NOT' offseted by VOL_BEGIN_SECT!
FAT_RGN_FAT     dw 0
FAT_RGN_ROOT    dw 0
FAT_RGN_DATA    dw 0

FAT_ROOTDIR_LEN         dw 0    ; Root directory len in sectors
FAT_FILE_NOT_FOUND      db "Couldn't find....",0
FAT_CLS_SIZE_IN_BYTES   dw 0    ; Cluster size in bytes for incrementing buffers
