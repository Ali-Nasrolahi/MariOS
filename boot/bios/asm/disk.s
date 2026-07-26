bits 16
;
; Disk Routines
;
; Constants:
SECTORS_PER_TRACK equ 512

; Error handlers

; Disk read error handler
disk_read_failed:
    mov si, DISK_ERROR
    call print
    mov dh, ah ; Error code
    call print_hex

    ; Wait for a keypress then reboot
    mov ah, 0
    int 0x16
    jmp acpi_reset


%ifdef ENABLE_DISK_FLOPPY
; Disk - Converts LBA (Linear Block Address) to CHS (Cylinder Head Sector) based on 512-byte sector
; Params:
;   - ax LBA Address
;
; Returns:
;   - cl [bits 0-5]:    sector no.
;   - cl [bits 6-7]:    high two bits of cylinder (bits 6-7, hard disk only)
;   - ch :              low eight bits of cylinder no.
;   - dh:               head no.
;
; Algorithm:
;   void ToCHS(int lba, int *head, int *track, int *sector)
;   {
;	    (*head) = (lba % (SECTORS_PER_TRACK * 2)) / SECTORS_PER_TRACK;
;	    (*track) = (lba / (SECTORS_PER_TRACK * 2));
;	    (*sector) = (lba % SECTORS_PER_TRACK + 1);
;   }
disk_lba_to_chs:
    ; used as a helper register
    push bx

; head = (lba % (SECTORS_PER_TRACK * 2)) / SECTORS_PER_TRACK;
    mov bx, ax
    and bx, (SECTORS_PER_TRACK * 2 - 1) ; n % m (if m is power of 2) ===> n & (m - 1)
    shr bx, 9                           ; n / m (if m is power of 2) ===> n >> lg(m)
    mov dh, bl

; sector = (lba % SECTORS_PER_TRACK + 1);
    mov bx, ax
    and bx, (SECTORS_PER_TRACK - 1)
    inc bx
    mov cl, bl

; track = (lba / (SECTORS_PER_TRACK * 2));
    mov bx, ax
    shr bx, 10
    mov ch, bl  ; Low 8 bits goes to ch

    ; CL = Sector | ((cylinder >> 2) & 0xC0)
    shr bx, 2
    and bx, 0b1100_0000
    or cl, bl

    pop bx
    ret



; Disk - Read sector(s) into memory
; Params:
;   - ax:       LBA Address
;   - dh:       No. of sector(s) to read (1-128)
;   - dl:       Drive ID
;
; Returns:
;   - [es:bx]:  Read sectors will copied into pointed buffer
disk_floppy_lba_read:

    push ax
    push dx

    call disk_lba_to_chs

    pop ax      ; dx -> ax (dh stores no. of sectors to be read)
    mov al, ah
    mov ah, 0x02
    mov di, 3

; Notes: Errors on a floppy may be due to the motor failing to spin up quickly enough
; the read should be retried at least three times, resetting the disk with AH=00h between attempts.
.retry:
    pusha
    stc         ; set cf, some BIOS'es don't set it
    int 0x13
    jnc .done   ; cf clear if successful

    popa

    ; Reset the disk
    mov ah, 0
    stc
    int 0x13
    jc disk_read_failed

    dec di
    test di, di
    jnz .retry
    jc disk_read_failed ; All attempts have failed

.done:
    popa
    pop ax
    ret

; ENABLE_DISK_FLOPPY
%endif

; Disk - Read sector(s) into memory
; Params:
;   - eax:      LBA Address
;   - cx:       No. of sector(s) to read (1 - 128)
;   - dl:       Drive ID
;
; Returns:
;   - [es:bx]:  Read sectors will copied into pointed buffer (make sure bx is word-aligned)
disk_hdd_lba_read:

    push ax
    push si

    ; Setup the DAP
    mov word    [DISK_PAKCET + 2], cx   ; no. sectors
    mov word    [DISK_PAKCET + 4], bx   ; offset
    mov word    [DISK_PAKCET + 6], es   ; segment
    mov dword   [DISK_PAKCET + 8], eax  ; LBA Address

    mov si, DISK_PAKCET ; Set pointer to packet

    mov ah, 0x42
    int 0x13
    jc disk_read_failed

    pop si
    pop ax
    ret

DISK_ERROR db "Disk read error ", 0

; Disk Address Packet
;
; Format of disk address packet:
; Offset    Size        Description
;
; 00h       BYTE        size of packet (10h)
; 01h       BYTE        reserved (0)
; 02h       WORD        number of sectors to transfer (max 127 on some BIOSes)
; 04h       DWORD       transfer buffer (16 bit segment:16 bit offset) (see note #1 & #2)
; 08h       DWORD       lower 32-bits of 48-bit starting LBA
; 12h       DWORD       upper 16-bits of 48-bit starting LBA
;
; (1) The 16 bit segment value ends up at an offset of 6 from the beginning of the structure
;    > i.e., when declaring segment:offset as two separate 16-bit fields, place the offset first
;       and then follow with the segment because x86 is little-endian).
;
; (2) The transfer buffer should be 16-bit (2 byte) aligned.

DISK_PAKCET:
db 0x10
db 0x00
dw 0x00 ; Sector no.
dd 0x00 ; buffer
dd 0x00 ; LBA lower 32-bit
dd 0x00 ; LBA higher 16-bit (why 4 bytes long?)
