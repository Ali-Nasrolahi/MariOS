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
;   Limitations:
;       - Fast A20 gate, instead of more reliable method
;
;
; ##############################################################
;                           CBoot
; ##############################################################

bits 16

%undef DEBUG

global _start
extern boot_main

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

    call a20_enable
    call a20_check
    cmp ax, 0
    jne .a20_is_up
    mov si, A20_DISABLED
    call print
    jmp halt

.a20_is_up:

	call cpuid_check
	cmp eax, 0
	jne .cpuid_is_available
    mov si, CPUID_NOT_SUPP
    call print
    jmp halt

.cpuid_is_available:

    cli
    lgdt [gdt_desc]
    mov eax, cr0
    or al, 0x1
    mov cr0, eax

    jmp 0x8:pm_start ; 0x8 offset of first segment (aka. gdt_code)

halt:
    cli
    hlt

bits 32

pm_start:

; TODO setup protected mode.

    mov ax, (0x8 * 2) ; Next entry in GDT (aka. gdt_data)
    mov ds, ax
    mov ss, ax
    mov es, ax
    mov fs, ax
    mov gs, ax


halt32:
    cli
    hlt


bits 16
%include "inc/gdt.inc"

%include "inc/acpi.s"
%include "inc/disk.s"
%include "inc/print.s"

; Checks if cpuid is supported. (credit to OSDev)
; Params:
;	eax[out] : 0 ==> not supported, non-zero ==> supported
cpuid_check:
    pushfd                      ;Save EFLAGS
    pushfd                      ;Store EFLAGS
    xor dword [esp], 0x00200000 ;Invert the ID bit in stored EFLAGS
    popfd                       ;Load stored EFLAGS (with ID bit inverted)
    pushfd                      ;Store EFLAGS again (ID bit may or may not be inverted)
    pop eax                     ;eax = modified EFLAGS (ID bit may or may not be inverted)
    xor eax, [esp]              ;eax = whichever bits were changed
    popfd                       ;Restore original EFLAGS
    and eax, 0x00200000         ;eax = zero if ID bit can't be changed, else non-zero
    ret

a20_enable:
    push ax
    in al, 0x92
    or al, 2
    out 0x92, al
    pop ax
    ret

; Tests if Gate-20 is enabled. (credit to OSDev)
; Params:
;   ax[out] : 0 => disabled, 1 => enabled
;
a20_check:
	pushf
	push si
	push di
	push ds
	push es
	cli

	mov ax, 0x0000          ;	0x0000:0x0500(0x00000500) -> ds:si
	mov ds, ax
	mov si, 0x0500

	not ax                  ;	0xffff:0x0510(0x00100500) -> es:di
	mov es, ax
	mov di, 0x0510

	mov al, [ds:si]         ;	save old values
	mov byte [.BufferBelowMB], al
	mov al, [es:di]
	mov byte [.BufferOverMB], al

	mov ah, 1
	mov byte [ds:si], 0
	mov byte [es:di], 1
	mov al, [ds:si]
	cmp al, [es:di]         ;	check byte at address 0x0500 != byte at address 0x100500
	jne .exit
	dec ah
.exit:
	mov al, [.BufferBelowMB]
	mov [ds:si], al
	mov al, [.BufferOverMB]
	mov [es:di], al
	shr ax, 8               ;	move result from ah to al register and clear ah
	sti
	pop es
	pop ds
	pop di
	pop si
	popf

.return:
	ret

.BufferBelowMB:	db 0
.BufferOverMB	db 0


CBOOT_WELCOME   db CRLF, '[CBoot]: loaded.', CRLF, 0
A20_DISABLED    db 'Gate-A20 is disabled', CRLF, 0
CPUID_NOT_SUPP 	db 'CPUID instruct is not supported.', CRLF, 0