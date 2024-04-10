[org 0x7c00]
[bits 16]

KERNEL_OFFSET equ 0x1000

; BIOS Parameter Block
; { BPB Begin
jmp short start
nop
times 33 db 0
; } BPB End

start:
    ; setup CS register
    jmp 0:._start
._start:

    ; Setup 16-bit segment registers and stack
    cli
    xor ax, ax
    mov ss, ax
    mov ds, ax
    mov es, ax
    mov sp, 0x7c00
    sti

    mov [BOOT_DRIVE], dl    ; Save boot drive
    mov si, MSG_REAL_MODE
    call print
    call print_crlf

    call kernel_load

    ; Switch to 32bit protected mode
    cli
    lgdt[gdt_descriptor]
    mov eax, cr0
    or  eax, 1
    mov cr0, eax
    jmp CODE_SEG:init_pm

kernel_load:

    mov si, MSG_LOAD_KERNEL
    call print
    call print_crlf

    mov bx, KERNEL_OFFSET; Read from disk and store in 0x1000
    mov dh, 2
    mov dl, [BOOT_DRIVE]
    call disk_load

    ret

[bits 32]
init_pm:

    mov ax, DATA_SEG
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax
    mov ebp, 0x00200000
    mov esp, ebp

    ; Enable fast A20 gate
    in al, 0x92
    or al, 2
    out 0x92, al

    ; call kernel_entry
    mov ebx, MSG_PROT_MODE
    call print32
    call KERNEL_OFFSET ; Give control to the kernel
    hlt; Stay here when the kernel returns control to us (if ever)

%include "boot/bios/print.s"
%include "boot/bios/disk.s"
%include "boot/bios/gdt.s"

BOOT_DRIVE db 0
MSG_REAL_MODE db "Started in 16-bit Real Mode", 0
MSG_PROT_MODE db "Landed in 32-bit Protected Mode", 0
MSG_LOAD_KERNEL db "Loading kernel into memory", 0

times 510 - ($-$$) db 0
dw 0xaa55