org 0x7c00
bits 16

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
boot_message: db "Our OS has booted!", 0x0d, 0x0a, 0
  

times 510-($-$$) db 0 ; Fill the rest of the sector with 0s
dw 0xaa55
