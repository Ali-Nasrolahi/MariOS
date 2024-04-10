[bits 16]
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

print_hex:
    pusha
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

    popa
    ret

.HEX_OUT:
    db '0x0000',0

[bits 32] ; using 32-bit protected mode

; this is how constants are defined
VIDEO_MEMORY equ 0xb8000
WHITE_ON_BLACK equ 0x0f ; the color byte for each character

print32:
    pusha
    mov edx, VIDEO_MEMORY

.print_string_pm_loop:
    mov al, [ebx] ; [ebx] is the address of our character
    mov ah, WHITE_ON_BLACK

    cmp al, 0 ; check if end of string
    je .print_string_pm_done

    mov [edx], ax ; store character + attribute in video memory
    add ebx, 1 ; next char
    add edx, 2 ; next video memory position

    jmp .print_string_pm_loop

.print_string_pm_done:
    popa
    ret


