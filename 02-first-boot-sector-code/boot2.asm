org 0x7c00

start:
    mov [boot_drive], dl   ; BIOS puts the boot drive number in dl automatically -
                           ; save it now, before we overwrite dl for anything else

    mov ah, 0x0e
    mov al, 'A'
    int 0x10               ; print 'A' - proves stage 1 is running

    mov ah, 0x02            ; BIOS function: read sectors from disk
    mov al, 1                ; how many sectors to read (1 = 512 bytes = stage 2)
    mov ch, 0                 ; cylinder 0
    mov cl, 2                 ; sector 2 (sector 1 is THIS boot sector; disk sectors
                               ; are numbered starting at 1, not 0)
    mov dh, 0                 ; head 0
    mov dl, [boot_drive]      ; which physical drive to read from
    mov bx, 0x7e00             ; where in RAM to put what we read
    int 0x13                   ; call the BIOS disk-read service

    jc disk_error              ; if the BIOS reported an error (carry flag set), bail

    jmp 0x7e00                  ; success - jump into stage 2

disk_error:
    mov ah, 0x0e
    mov al, 'E'                  ; print 'E' so we know loading failed
    int 0x10

hang:
    jmp hang

boot_drive: db 0

times 510-($-$$) db 0
dw 0xaa55
