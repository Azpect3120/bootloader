org 0x0
bits 16

start:
  mov si, os_boot_msg
  call print
  hlt

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

os_boot_msg: db "Kernel has been loaded", 0x0d, 0x0a, 0
