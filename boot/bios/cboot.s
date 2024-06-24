; ##############################################################
;                          CBoot
; ##############################################################
; Main bootloader:
;
;   CBoot is last stage of booting process, which setups
;   whatever kernel requires.
;
;   Structure Overview:
;       - Loaded at 0x8e00
;       - Stack: 0x8000 to 0x8e00 (Around 3KB)
;
;
; ##############################################################
;                           CBoot
; ##############################################################

bits 16

%undef DEBUG

global _start

section .boot

_start:

    cli
    ; Setup registers and stack
    xor ax, ax
    mov ss, ax
    mov ds, ax
    mov es, ax
    mov sp, 0x8e00
    mov bp, sp
    ; end of setup
    sti

    mov si, CBOOT_WELCOME
    call print

halt:
    cli
    hlt

%include "inc/acpi.s"
%include "inc/disk.s"
%include "inc/print.s"

CBOOT_WELCOME  db CRLF, '[CBoot]: loaded.', CRLF, 0
