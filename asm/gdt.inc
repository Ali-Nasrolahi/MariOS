bits 16

; GDT Setup Overview
;
; Two segments has initialized, one for code and the other for data.
; Bases are 0x0 and limits are 0xffff with granularity flag set for both.
; Which indicates the size the Limit value is scaled by 4KiB blocks, by that
; the segment will span the full 4 GiB address space in 32-bit mode.
;
; The only differnce between the two segments is E flag in access byte.
;  Access Byte: P, S, RW ==> Enabled, DPL, DC, A ==> Disabled
;  and E is enabled for gdt_code and disabled for gdt_data.
;
; Note:
;   By standard first 8 bytes of gdt should be null and unsued, nevertheless
;   we could just use it for GDT Descriptor instead.
gdt_start:
gdt_desc:
    dw gdt_end - gdt_start - 1  ; Size of the table - 1, Why -1 ?
                                ; refer to https://wiki.osdev.org/Global_Descriptor_Table#GDTR

    dd gdt_start                ; Offset: The linear address of the GDT
    dw 0x0                      ; rest of null bytes


gdt_code:
    dw 0xffff   ; Limit         (offset 00-15):(low 16 bits)
    dw 0x0      ; Base          (offset 16-31):(low 16 bits)
    db 0x0      ; Base          (offset 32-39):(next 8 bits)
    db 0x9a     ; Access Byte   (offset 40-47)
    db 0xcf     ; Limit         (lower 4 bits for limit's higher 4 bits):(offset 48-51)
                ; Flags         (higher 4 bits):(offset 52-55)
    db 0x0      ; Base          (offset 56-63):(higher 8 bits)

gdt_data:
    dw 0xffff   ; Limit         (offset 00-15):(low 16 bits)
    dw 0x0      ; Base          (offset 16-31):(low 16 bits)
    db 0x0      ; Base          (offset 32-39):(next 8 bits)
    db 0x92     ; Access Byte   (offset 40-47)
    db 0xcf     ; Limit         (lower 4 bits for limit's higher 4 bits):(offset 48-51)
                ; Flags         (higher 4 bits):(offset 52-55)
    db 0x0      ; Base          (offset 56-63):(higher 8 bits)

gdt_end: