; ##############################################################
;                           Core
; ##############################################################
; Booting stage 2 (aka. CBoot)
;
;   This stage was inspired by GRUB architecture which include
;   three stages. First two stages are just designed for booting
;   last one. Multiple limitations and assumptions took in for
;   easier implementation, check 'limit.md'.
;
;   Overview:
;       - First display partitions, and let user select appropriate one.
;       - Initialize FAT fields to work with filesystem
;       - Find BOOT_BIN_FILENAME and load it
;
; ##############################################################
;                           Core
; ##############################################################

org 0x0600
bits 16

PT_BASE_ADDR    equ (0x7c00 + 0x1be)    ; Address of MBR table beginning
CBOOT_ADDR      equ (0x9e00)            ; boot.bin will be loaded in

%undef DEBUG

%include "inc/bpb.inc"


_start:

    cli
    ; Setup registers and stack
    xor ax, ax
    mov ss, ax
    mov ds, ax
    mov es, ax
    mov sp, 0x0600; 0x0500 to 0x0600 could be used as stack (256 bytes)
    mov bp, sp
    ; end of setup
    sti

    mov [bpb_drive_no], dl
    mov si, WELCOME
    call print


SelectPartition:

    mov bx, PT_BASE_ADDR
    mov cx, 4
    mov bp, sp

.lp1:
    mov al, [bx]
    test al, 0x80
    jnz .found
    jmp .cont

.found:
    mov si, BOOTING_LABLE
    call print
    mov dx, bx
    call print_hex
    mov al, [BOOTING_LABLE]
    inc al
    mov [BOOTING_LABLE], al
    push bx
    inc byte [TMP_BT_NO]

.cont:
    add bx, 0x10
    dec cx
    jnz .lp1

    ; Wait for user to choose a partition
    mov ah, 0
    int 0x16

    ; make the number's char to integer
    sub al, '0'
    and ax, 0b11 ; 0 to 3 only
    mov cl, [TMP_BT_NO]
    sub cl, al

    ; pop N-th partition address to bx
.lp2:
    pop bx
    loop .lp2
    mov sp, bp

    call print_crlf
    mov si, BOOTING_FROM
    call print
    mov dx, bx
    call print_hex

LoadCBoot:

    ; Init FAT stuff. Make sure following are set correctly:
    ;   - bx = loaded partition address
    ;   - bpb_drive_no
    ; Rest will be calculated in init method.

    call fat_init
    call fat_load_rootdir
    mov si, CBOOT_FILENAME
    call fat_find_file
    jnc .found
    mov si, ST2_NOT_FOUND
    call print
    jmp halt

.found:
    push di ; Save Boot.bin cluster no.

.load_the_table:
    call fat_load_table

.load_the_file:
    pop ax ; Restore Boot.bin cluster no.
    mov bx, CBOOT_ADDR
    call fat_load_cls_chain

    mov dx, [CBOOT_ADDR]
    call print_hex

Stage2:

halt:
    cli
    hlt

%include "inc/acpi.s"
%include "inc/disk.s"
%include "inc/fat.s"
%include "inc/print.s"

WELCOME     db  'Welcome to MariOS', CRLF, 0

TMP_BT_NO       db  0
BOOTING_LABLE   db  '0. Bootable Partition at ', 0
BOOTING_FROM    db  'Booting from....... ', 0
NO_BOOTABLE_PT  db  'No bootable partition!', 0

CBOOT_FILENAME      db 'CBOOT   BIN', 0
ST2_NOT_FOUND       db 'Cannot find stage2 file!', 0

times (1022 - $ + $$) db 0