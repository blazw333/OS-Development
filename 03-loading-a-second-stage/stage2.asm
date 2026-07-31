org 0x7e00              ; tell the assembler this code loads at address 0x7E00

start:
    mov ah, 0x0e         ; BIOS function: print one character
    mov al, 'B'          ; the character to print - 'B' proves stage 2 ran
    int 0x10             ; call the BIOS video service

hang:
    jmp hang             ; infinite loop - stay here forever
