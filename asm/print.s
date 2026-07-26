bits 16

%define CRLF 0xa, 0xd

; Prints a string
; [param] si -> pointer to message
print:
    push ax
    mov ah, 0x0e ; Int 10/AH=0Eh - VIDEO - TELETYPE OUTPUT
.nextc:
    lodsb
    cmp al, 0
    je short .done
    int 0x10
    jmp short .nextc
.done:
    pop ax
    ret

; Prints CRLF
print_crlf:
    push ax
    mov ah, 0x0e ; Int 10/AH=0Eh - VIDEO - TELETYPE OUTPUT
    mov al, 0x0a ; LF
    int 0x10
    mov al, 0x0d ; CR
    int 0x10
    pop ax
    ret

; prints dx
print_hex:
    push ax
    push bx
    push cx
    push si

    mov cx, 0
.hex_loop:
    cmp cx, 4
    je .end
    mov ax, dx
    and ax, 0x000f
    add al, 0x30
    cmp al, 0x39
    jle .step2
    add al, 7
.step2:
    mov bx, .HEX_OUT + 5
    sub bx, cx
    mov [bx], al
    ror dx, 4
    add cx, 1
    jmp .hex_loop

.end:
    mov si, .HEX_OUT
    call print

    pop si
    pop cx
    pop bx
    pop ax
    ret

.HEX_OUT:
    db '0x0000', CRLF, 0