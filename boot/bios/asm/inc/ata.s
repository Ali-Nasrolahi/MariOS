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

.wait_for_DRQ:
    in al, dx       ; Status Register (I/O base + 7)
    test al, 8      ; DRQ Set when the drive has PIO data to transfer, or is ready to accept PIO data.
    jz .wait_for_DRQ

    mov eax, 256    ; to read 256 words = 1 sector
    xor bx, bx
    mov bl, cl      ; read cl sectors
    mul bx
    mov ecx, eax    ; ecx is counter for INSW
    mov edx, 0x1f0  ; Data port, in and out
    rep insw        ; in to [edi]

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

    ret