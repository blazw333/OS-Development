# Why the CPU Reads from RAM, Not the SSD

## The chain of events

Before the operating system can run, the very first job at boot time belongs to the
**BIOS** — a small, permanent program built into the motherboard, separate from
everything on the SSD.

The BIOS's job is simple but critical: it reads the very first **512 bytes** of the
operating system off the SSD and copies them into **RAM**, at a specific, fixed memory
address: **`0x7C00`**.

## Why this copy step is necessary

The operating system lives permanently on the SSD. But the CPU — the part of the
computer that actually executes instructions — **cannot read information directly
from the SSD**. It's physically wired to only read from RAM.

This means nothing on the SSD can ever run as-is. Before the CPU can execute any of
it, something has to move it into RAM first. At the very start of the boot process,
before an OS is even loaded, that "something" is the BIOS.

## The sequence, step by step

1. The SSD holds the operating system, but it's just sitting there — untouched, not
   running.
2. The BIOS reads the first 512 bytes of that OS off the SSD.
3. The BIOS copies those 512 bytes into RAM, specifically at address `0x7C00`.
4. The CPU is pointed at that address and begins reading — and running — the
   instructions now sitting there.

In short: the SSD stores the OS permanently, but the CPU can only ever read from RAM —
so the BIOS's whole purpose at this stage is to bridge that gap, copying just enough
of the OS from the SSD into RAM to get things started.
