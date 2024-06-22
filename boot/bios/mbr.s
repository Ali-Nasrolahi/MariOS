; ##############################################################
;                       MBR Bootstrap
; ##############################################################
;   MBR Bootstrap:
;       Loads stage 1.5 into 0:0x0600.
;
;       This bootstrap tries to minimal as possible to fit into MBR
;       whih leaves us with around 400 bytes, which is not flexible enough
;       for working with filesystems and partitions. So we try to
;       learn from masters and do as GRUB did.  [https://en.wikipedia.org/wiki/GNU_GRUB]
;
;       Stage 1 (this file) is just a simple bootstrap program to load next stage (stage 1.5)
;       which resides between MBR and first parttion, aka. 'core.bin'. This method makes it
;       a lot easier to maintain and improve.
;
;       Neither stage 1(mbr) nor stage 1.5(core) 'relocate' themselves to 0x0600, on the other hand
;       mbr loads core into 0x0600 initially. Besides this, core actually useses the partition table
;       which is already loaded by bios (first sector of HDD), i.e. 0x1be, 0x1ce, 0x1de, 0x1ee of disk.
;
; ##############################################################
;                       MBR Bootstrap
; ##############################################################
org 0x7c00
bits 16

%undef DEBUG

_start:
    ; Setup registers and stack
    cli
    xor ax, ax
    mov ss, ax
    mov ds, ax
    mov es, ax
    mov sp, 0x0600  ; 0x0500 to 0x0600 could be used as stack (256 bytes)
    ; end of setup

    ; Save stuff we need later
    mov [DRIVE_NO], dl

    mov eax, 1
    mov cx, 2
    mov bx, 0x0600
    call disk_hdd_lba_read

    ; Restore stuff that core needs
    mov dl, [DRIVE_NO]

    jmp 0:0x0600

    mov si, CORE_MESS
    call print

    cli
    hlt

%include "inc/acpi.s"
%include "inc/disk.s"
%include "inc/print.s"

CORE_MESS   db  'Core (stage 1.5) messed up!!', CRLF, 0
DRIVE_NO    db  0x00

; This piece of code will be placed in
; MBR sector and exactly before partition table.
; For more info check: https://wiki.osdev.org/MBR_(x86)
times (0x1b8 - ($-$$)) db 0
