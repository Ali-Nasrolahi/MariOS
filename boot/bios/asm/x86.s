bits 32

global outb
global inb
global rep_outsw
global rep_insw

; outb(uint16_t port, uint8_t val);
outb:
    mov dx, [esp + 4]
    mov al, [esp + 8]
    out dx, al
    ret

; inb(uint16_t port);
inb:
    mov dx, [esp + 4]
    xor eax, eax
    in al, dx
    ret

; rep_outsw(uint16_t port, void *buf, uint32_t size);
rep_outsw:
    mov dx, [esp + 4]
    mov esi, [esp + 8]
    mov ecx, [esp + 12]
    rep outsw
    ret

; void __attribute__((cdecl)) rep_insw(uint16_t port, void *buf, uint32_t size);
rep_insw:
    mov dx, [esp + 4]
    mov edi, [esp + 8]
    mov ecx, [esp + 12]
    rep insw
    ret
