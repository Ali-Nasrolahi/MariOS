bits 32

global _ata_lba_read
global _ata_lba_write

; Read from first hard disk (0x80).
; 28-bit PIO Mode: https://wiki.osdev.org/ATA_PIO_Mode#28_bit_PIO
; Based on : https://wiki.osdev.org/ATA_read/write_sectors#Read_in_LBA_mode
; Params:
;   eax :   LBA Address
;   cl  :   Sectors no. to read
;   edi :   Pointer to the destination buffer
; C Declaration:
;   _ata_lba_read(uint32_t addr, void *buf, uint8_t sect);
_ata_lba_read:
    push ebp
    mov ebp, esp

    mov eax, [ebp + 8]
    mov edi, [ebp + 12]
    mov cl, [ebp + 16]

    mov ebx, eax    ; Store LBA address

    mov edx, 0x1f2  ; Send No. of sectors
    mov al, cl
    out dx, al
    mov eax, ebx

    inc edx         ; Send LBAlo (bit 0 - 7)
    out dx, al

    inc edx         ; Send LBAmid (bit 8 - 15)
    shr eax, 8
    out dx, al

    inc edx         ; Send LBAhi (bit 16 - 23)
    shr eax, 8
    out dx, al

    inc edx         ; Drive / Head Register (I/O base + 6)
    shr eax, 8      ; Send LBA last 4 bits (bit 24 - 27)
    or al, 0xe0     ; Enable 6th bit (LBA Mode)
    out dx, al

    inc edx         ; 'edx=0x1F7' Command Port
    mov al, 0x20    ; Read with retry (https://wiki.osdev.org/ATA_Command_Matrix)
    out dx, al

    mov ebx, ecx    ; Store sect no. in ebx

    ; ignore the error bit for the first 4 status reads
    ; ie. implement 400ns delay on ERR only
    ; wait for BSY clear and DRQ set
    mov ecx, 4
.lp1:
    in al, dx           ; grab a status byte
    test al, 0x80       ; BSY flag set?
    jne short .retry
    test al, 8          ; DRQ set?
    jne short .data_rdy
.retry:
    dec ecx
    jg short .lp1

; need to wait some more
; loop until BSY clears or ERR sets (error exit if ERR sets)
.pior_l:
    in al, dx           ; grab a status byte
    test al, 0x80       ; BSY flag set?
    jne short .pior_l   ; (all other flags are meaningless if BSY is set)
    test al, 0x21       ; ERR or DF set?
    jne short .fail

.data_rdy:
    ; if BSY and ERR are clear then DRQ must be set
    ; go and read the data
    sub dl, 7   ; read from data port (ie. 0x1f0)
    mov cx, 256
    rep insw    ; gulp one 512b sector into edi
    or dl, 7    ; "point" dx back at the status register
    in al, dx   ; delay 400ns to allow drive to set new values of BSY and DRQ
    in al, dx
    in al, dx
    in al, dx

    ; After each DRQ data block it is mandatory to either:
    ; receive and ack the IRQ -- or poll the status port all over again
    dec ebx         ; decrement the "sectors to read" count
    test bl, bl     ; check if the low byte just turned 0 (more sectors to read?)
    jne short .pior_l

    sub dx, 7       ; "point" dx back at the base IO port, so it's unchanged

    ; "test" sets the zero flag for a "success" return
    ; also clears the carry flag
    test al, 0x21       ; test the last status ERR bits
    je short .done
.fail:
    stc
.done:
    pop ebp
    ret


; Write to first hard disk (0x80).
; 28-bit PIO Mode: https://wiki.osdev.org/ATA_PIO_Mode#28_bit_PIO
; Based on : https://wiki.osdev.org/ATA_read/write_sectors#ATA_write_sectors
; Params:
;   eax :   LBA Address
;   cl  :   Sectors no. to write
;   edi :   Pointer to the src buffer
; C Declaration:
;   _ata_lba_write(uint32_t addr, void *buf, uint8_t sect);
_ata_lba_write:
    push ebp
    mov ebp, esp

    mov eax, [ebp + 8]
    mov edi, [ebp + 12]
    mov cl, [ebp + 16]


    mov ebx, eax    ; Store LBA address

    mov edx, 0x1f2  ; Send No. of sectors
    mov al, cl
    out dx, al
    mov eax, ebx

    inc edx         ; Send LBAlo (bit 0 - 7)
    out dx, al

    inc edx         ; Send LBAmid (bit 8 - 15)
    shr eax, 8
    out dx, al

    inc edx         ; Send LBAhi (bit 16 - 23)
    shr eax, 8
    out dx, al

    inc edx         ; Drive / Head Register (I/O base + 6)
    shr eax, 8      ; Send LBA last 4 bits (bit 24 - 27)
    or al, 0xe0     ; Enable 6th bit (LBA Mode)
    out dx, al

    inc edx         ; 'edx=0x1F7' Command Port
    mov al, 0x30    ; Write with retry (https://wiki.osdev.org/ATA_Command_Matrix)
    out dx, al

.wait_for_DRQ:
    in al, dx       ; Status Register (I/O base + 7)
    test al, 8      ; DRQ Set when the drive has PIO data to transfer, or is ready to accept PIO data.
    jz .wait_for_DRQ

    mov eax, 256    ; to write 256 words = 1 sector
    xor bx, bx
    mov bl, cl      ; write cl sectors
    mul bx
    mov ecx, eax    ; ecx is counter for INSW
    mov edx, 0x1f0  ; Data port, in and out
    mov esi, edi
    rep outsw        ; write on disk

    pop ebp
    ret

; do a singletasking PIO ata "software reset" with DCR in dx
srst_ata_st:
    push eax
    mov al, 4
    out dx, al          ; do a "software reset" on the bus
    xor eax, eax
    out dx, al          ; reset the bus to normal operation
    in al, dx           ; it might take 4 tries for status bits to reset
    in al, dx           ; ie. do a 400ns delay
    in al, dx
    in al, dx
.rdylp:
    in al, dx
    and al, 0xc0            ; check BSY and RDY
    cmp al, 0x40            ; want BSY clear and RDY set
    jne short .rdylp
    pop eax
    ret