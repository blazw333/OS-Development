# The First 512 Bytes: Writing and Running a Real Boot Sector

This folder contains `boot2.asm` — a minimal, working x86 boot sector that prints the
letter `A` to the screen. This README explains what the code does, and walks through
assembling it and running it yourself, on Windows, using NASM and VMware.

## The code

```nasm
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






### Line by line

- **`org 0x7c00`** — Tells the assembler this code will physically sit at memory
  address `0x7C00` once loaded (see [`01-cpu-ram-vs-ssd`](../01-cpu-ram-vs-ssd)), so
  any address math it does is correct.
- **`mov ah, 0x0e`** — Copies the value `0x0E` into the CPU register `ah`. This value
  is a code the BIOS recognizes as "print a single character."
- **`mov al, 'A'`** — Copies the letter `A` (its numeric value, `0x41`) into register
  `al` — this is the character that will actually get printed.
- **`int 0x10`** — Triggers a BIOS interrupt. This pauses our code and hands control
  to the BIOS's own built-in screen-printing routine, which reads `ah`/`al` and draws
  the letter on screen. The CPU itself has no idea how to talk to a screen — only the
  BIOS's prewritten code knows how. Once done, control returns to the next line.
- **`hang: jmp hang`** — An infinite loop. Keeps the CPU safely parked here instead of
  running into whatever random bytes come next in memory.
- **`times 510-($-$$) db 0`** — Fills every remaining byte with zero, up to byte 510.
- **`dw 0xaa55`** — The boot signature. The BIOS checks bytes 510–511 for exactly this
  value before it will treat the sector as bootable.

The whole file is required to be **exactly 512 bytes** — that's the fixed size the
BIOS always reads and always checks for a signature on.

---

## Running it yourself (Windows)

### 1. Install NASM

Download the installer from [nasm.us](https://www.nasm.us) → click the latest stable
version number → grab the `win64` installer (`...-installer-x64.exe`) → run it.

Note the install folder — it's often somewhere like:

```
C:\Users\<yourname>\AppData\Local\bin\NASM
```

### 2. Assemble the code

Open Command Prompt, navigate to this folder, then run NASM (using its full path if
it's not on your PATH):

```
cd path\to\02-first-boot-sector-code
"C:\Users\<yourname>\AppData\Local\bin\NASM\nasm.exe" -f bin boot2.asm -o boot2.bin
```

This produces `boot2.bin` — the raw, exactly-512-byte machine code file. Confirm the
size with:

```
dir boot2.bin
```

It should read exactly **512 bytes**.

### 3. Turn it into a floppy image for VMware

VMware's floppy drive expects a full 1.44MB image, so pad the file out. Open
**PowerShell** (not Command Prompt) in the same folder:

```powershell
Copy-Item boot2.bin boot2.img
$fs = [System.IO.File]::OpenWrite((Resolve-Path boot2.img))
$fs.SetLength(1474560)
$fs.Close()
```

Confirm it worked:

```
dir boot2.img
```

It should read exactly **1,474,560 bytes**. Your actual code still lives in the first
512 bytes — everything after is just empty padding to satisfy VMware's size check.

### 4. Set up the VM in VMware

1. Create a new VM: **Create a New Virtual Machine** → **I will install the operating
   system later** → guest OS type **Other** (you're not installing a real OS).
2. With the VM powered off, open **Edit virtual machine settings**.
3. Add or edit a **Floppy** device → choose **Use floppy image file** → browse to
   your `boot2.img`.
4. Make sure **Connect at power on** is checked.

### 5. Boot it

Click **Power On**. VMware's virtual BIOS will:

1. Read the first 512 bytes off `boot2.img`.
2. Check for the `0xAA55` signature at bytes 510–511.
3. Copy the sector into RAM at `0x7C00`.
4. Jump the CPU there.

If everything assembled and loaded correctly, you'll see the letter **`A`** appear on
an otherwise blank screen — proof that every step above actually worked, from your
source code down to the exact bytes the CPU executed.

---

## What to try next

- Change `mov al, 'A'` to print a different character, or add more `mov`/`int 0x10`
  pairs to print multiple characters.
- Explore [`01-cpu-ram-vs-ssd`](../01-cpu-ram-vs-ssd) if you haven't already, for the
  background on why this 512-byte/`0x7C00` setup exists in the first place.
  This is how the work should look like after it works

  <img width="1920" height="1001" alt="image" src="https://github.com/user-attachments/assets/82b5fc58-5303-4e80-806e-43f21c143d03" />
