; ########################
; ### Testing Routines ###
; ########################
;
;
%ifdef DEBUG

; Tests Disk reading
; Loads second (LBA 1) of dl into es:0x7e00 and prints two bytes from that location
;
test_disk_read:
    pusha
    mov ax, 1           ; From LBA 1 of dl
    mov dh, 1           ; read 1 sector
    mov bx, 0x7e00      ; and load into es:0x7e00
%ifdef ENABLE_DISK_FLOPPY
    call disk_floppy_lba_read
%else
    call disk_hdd_lba_read;
%endif
    mov dx, word [0x7e00]
    call print_hex
    popa
    ret

; DEBUG
%endif
