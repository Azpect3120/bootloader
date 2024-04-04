# Booting from scratch
Loads memory into the address *0x7C00*

Looks for the signature of the boot sector *0x55AA* at the end of the sector, the *last two* bytes.

Using the *times* direction to fill the rest of the sector with zeros.

```nasm
; ($-$$) is the current address minus the start address
; db is the data byte direction
times 510-($-$$) db 0
```
We have to set the bits to 16 at the start because all systems START at 16 bits to ensure compatibility with older systems

# Disks

CHS: Cylinder, Head, Sector

LBA: Logical Block Address

## Converting CHS to LBA

LBA = (C * TH * TS) + (H * TS) + (S - 1)

C = Sector cylinder number

TH = Total headers on disk

TS = Total sections on disk

H = Sector head number

S = Sector's number

## Converting LBA to CHS
t = LBA / sectors per track

S = (LBA % sectors per track) + 1

H = t % number of heads

C = t / number of headers

## 16 Bit C Compiler
```
https://github.com/open-watcom/open-watcom-v2/releases
```
