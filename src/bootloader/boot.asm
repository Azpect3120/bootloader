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

  ; https://stanislavs.org/helppc/int_13-2.html
  mov [ebr_drive_number], dl
  mov ax, 1
  mov cl, 1
  mov bx, 0x7E00
  call disk_read


  mov si, boot_message
  call print


  ; 4 Segments
  ; =========================
  ; reserved segment: 1 sector
  ; FAT: 18 sectors (fat_count * sectors_per_fat)
  ; Root directory
  ; Data directory

  mov ax, [bdb_sectors_per_fat]
  mov bl, [bdb_fat_count]
  xor bh, bh
  mul bx
  add ax, [bdb_reserved_sectors]   ; LBA of the root directory
  push ax                          ; Save the root directory LBA in the stack

  mov ax, [bdb_dir_entires_count]
  shl ax, 5 ;ax *= 32
  xor dx, dx
  div word [bdb_oem_per_sector] ;(32 * num of entires) / bytes per sector

  test dx, dx
  jz root_dir_after
  inc ax

  root_dir_after:
    ; Load root directory into the buffer
    mov cl, al    ; Number of sectors to read: size of root directory
    pop ax        ; Pop the root directory LBA
    mov dl, [ebr_drive_number]
    mov bx, buffer
    call disk_read

    xor bx, bx
    mov di, buffer

  search_kernel:
    mov si, file_kernal_bin
    mov cx, 11
    push di         ; Push buffer to stack
    repe cmpsb      ; Repeat comparison of bytes between si and di
    pop di          ; Pop buffer from stack
    je found_kernel ; Found kernel

    add di, 32
    inc bx
    cmp bx, [bdb_dir_entires_count] ; Check if we have reached the end of the root directory/searched them all
    jl search_kernel

    kernel_not_found:
      mov si, msg_kernel_not_found
      call print

    hlt
    jmp halt

found_kernel:
  mov ax, [di + 26]           ; di is the address of the kernel and 26 is the offset to the first logical cluster field
  mov [kernel_cluster], ax    ; Store the first logical cluster of the kernel

  mov ax, [bdb_reserved_sectors]
  mov bx, buffer
  mov cl, [bdb_sectors_per_fat]
  mov dl, [ebr_drive_number]

  call disk_read

  ; Prepare to load the kernel
  mov bx, kernel_load_segment
  mov es, bx
  mov bx, kernel_load_offset


load_kernel_loop:
  mov ax, [kernel_cluster]    ; Current cluster to read
  add ax, 31                  ; 31 is the offset to the next cluster field. Should be changed to be dynamic but for now its fine
  mov cl, 1
  mov dl, [ebr_drive_number]

  call disk_read

  add bx, [bdb_oem_per_sector]
  
  mov ax, [kernel_cluster]   ; (kernel cluster * 3) / 2    to find the next cluster location
  mov cx, 3
  mul cx
  mov cx, 2
  div cx

  mov si, buffer
  add si, ax
  mov ax, [ds:si]
  
  ; If the cluster is odd we need the upper 12 bits
  ; If the cluster is even we need the lower 12 bits
  or dx, dx
  jz even

odd: 
  shr ax, 4
  jmp next_cluster_after

even:
  and ax, 0x0FFF

next_cluster_after:
  cmp ax, 0x0FF8
  jae read_finish

  mov [kernel_cluster], ax
  jmp load_kernel_loop

read_finish:
  mov dl, [ebr_drive_number]
  mov ax, kernel_load_segment
  mov ds, ax
  mov es, ax

  jmp kernel_load_segment:kernel_load_offset  ; Jump to the kernel
  hlt

; Infinite loop to halt the CPU
halt:
  jmp halt

; input - ax: LBA index
; output - cx [bits 0-5]: sector number
; output - cx [bits 6-15]: cylinder
; output - dh: head
lbs_to_chs: 
  push ax
  push dx

  xor dx, dx  ; 0 out dx
  div word [bdb_sectors_per_track]  ; (LBA % sectors per track) + 1 = sector value
  inc dx          ; Sector value
  mov cx, dx      ; Store sector value in cx

  xor dx, dx  ; 0 out dx
  div word [bdb_heads]
  mov dh, dl      ; Store head value
  mov ch, al
  shl ah, 6       ; Move the cylinder value to the upper bits
  or cl, ah       ; Setup cylinder

  pop ax
  mov dl, al
  pop ax
  ret
  
  ; View `README.md` for the math behind this
  ; head = (LBA / sectors per track) % number of heads
  ; cylinder = (LBA / sectors per track) / number of heads

disk_read:
  push ax
  push bx
  push cx
  push dx
  push di

  call lbs_to_chs

  mov ah, 02h
  mov di, 3   ; counter

retry:
  stc
  int 13h
  jnc done_read

  call disk_reset

  dec di
  test di, di
  jnz retry

fail_disk_read:
  mov si, read_failure
  call print
  hlt
  jmp halt

disk_reset:
  pusha
  mov ah, 0
  stc
  int 13h
  jc fail_disk_read
  popa
  ret

done_read:
   pop di
   pop dx
   pop cx
   pop bx
   pop ax
   
   ret

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

;
; Messages
; 0x0d, 0x0a is a new line character and the 0 terminates the string
;
boot_message: db "Bootloader has booted successfully", 0x0d, 0x0a, 0
read_failure: db "Failed to read disk", 0x0d, 0x0a, 0
msg_kernel_not_found: db "KERNEL.BIN not found", 0x0d, 0x0a, 0

;
; Kernel data
;
file_kernal_bin db "KERNEL  BIN"  ; 11 bytes
kernel_cluster dw 0
kernel_load_segment equ 0x2000 ; Where to load the kernel into memory: memory address
kernel_load_offset equ 0

times 510-($-$$) db 0 ; Fill the rest of the sector with 0s
dw 0xaa55

; Where to place the data read from the disk
buffer: 
