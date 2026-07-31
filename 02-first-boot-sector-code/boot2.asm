org 0x7c00

start:
    mov ah, 0x0e      ; tell the BIOS "I want to print one character"
    mov al, 'A'       ; the character I want to print is the letter A
    int 0x10          ; ask the BIOS to actually do it

hang:
    jmp hang          ; loop forever

times 510-($-$$) db 0 ; pad with zeros up to byte 510
dw 0xaa55              ; the boot signature, at bytes 510-511

