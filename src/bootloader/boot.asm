org 0x7c00
bits 16

; Jump past FAT-12 header
jmp short main
nop

; FAT-12 header
bdb_oem:                  db  "MSWIN4.1"
bdb_oem_per_sector:       dw  512
bdb_sectors_per_cluster:  db  1
bdb_reserved_sectors:     dw  1
bdb_fat_count:            db  2
bdb_dir_entires_count:    dw  0E0h
bdb_total_sectors:        dw  2880    ; Matches the count from the Makefile, how many 512 sectors are in the disk
bdb_media_descriptor:     db  0F0h
bdb_sectors_per_fat:      dw  9
bdb_sectors_per_track:    dw  18
bdb_heads:                dw  2
bdb_hidden_sectors:       dd  0
bdb_large_sector_count:   dd  0

ebr_drive_number:         db  0 
                          db  0
ebr_signature:            db  29h
ebr_volume_id:            db  12h, 34h, 56h, 78h
ebr_volume_label:         db  "NEW OS     "      ; 11 bytes
ebr_system_id:            db  "FAT12   "         ; 8 bytes



main:
  mov ax, 0
  mov ds, ax
  mov es, ax
  mov ss, ax

  mov sp, 0x7c00
  mov si, boot_message
  call print

  hlt      ; Jump to halt

; Infinite loop to halt the CPU
halt:
  jmp halt

; Print a message to the screen
print:
  push si
  push ax 
  push bx

print_loop:
  lodsb           ; Returns value to al
  or al, al       ; Check if the character is 0
  jz print_done

  mov ah, 0x0e    ; BIOS teletype function, prints character in al
  mov bh, 0x00    ; Page number, used for printing to different pages of memory (we only have one)
  int 0x10        ; Call the BIOS interrupt

  jmp print_loop  ; Iterate

print_done:
  pop bx
  pop ax
  pop si
  ret

; 0x0d, 0x0a is a new line character and the 0 terminates the string
boot_message: db "Bootloader has booted successfully", 0x0d, 0x0a, 0
  

times 510-($-$$) db 0 ; Fill the rest of the sector with 0s
dw 0xaa55
