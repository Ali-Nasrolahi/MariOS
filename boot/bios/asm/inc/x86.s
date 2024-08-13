bits 32

global outb
global inb

; x86_outb(uint16_t port, uint8_t val);
outb:
    mov dx, [esp + 4]
    mov al, [esp + 8]
    out dx, al
    ret

; x86_inb(uint16_t port);
inb:
    mov dx, [esp + 4]
    xor eax, eax
    in al, dx
    ret
