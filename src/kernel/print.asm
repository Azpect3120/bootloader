bits 16

section _TEXT class=CODE

global _x86_Video_WriteCharTeletype
_x86_Video_WriteCharTeletype:
  push bp
  mov bp, sp

  push bx

  mov ah, 0Eh
  mov al, [bp+4]  ; Char to print
  mov bh, [bp+6]  ; Memory page number

  int 10h
  
  pop bx
  mov sp, bp
  pop bp
  
  ret

global _x86_Video_WriteCharTeletypeLine
_x86_Video_WriteCharTeletypeLine:
  push bp
  mov bp, sp

  push bx

  mov ah, 0Eh
  mov al, [bp+4]
  mov bh, [bp+6]
  int 10h

  mov ah, 0Eh
  mov al, 0x0d
  int 10h

  mov ah, 0Eh
  mov al, 0x0a
  int 10h

  pop bx
  mov sp, bp
  pop bp

  ret

global _x86_Video_WriteStringTeletype
_x86_Video_WriteStringTeletype:
  push bp
  mov bp, sp

  push bx
  push cx   ; Counter
  
  mov bx, [bp+4]    ; Load address of string into bx
  mov ah, 0Eh       ; Interrupt code

  print_loop:
    mov al, [bx]    ; Load current character at the address to al
    test al, al     ; Check if at end of string, val is 0
    jz end_print

    mov bh, [bp+6]  ; Load page value into bh
    int 10h         ; Call BIOS interrupt
    inc bx
    jmp print_loop

  ; Reverse all the memory changes we made
  end_print:
    pop cx
    pop bx
    mov sp, bp
    pop bp
    ret

global _x86_Video_WriteStringTeletypeLine
_x86_Video_WriteStringTeletypeLine:
  push bp
  mov bp, sp

  push bx
  push cx   ; Counter
  
  mov bx, [bp+4]    ; Load address of string into bx
  mov ah, 0Eh       ; Interrupt code

  print_loop_newline:
    mov al, [bx]    ; Load current character at the address to al
    test al, al     ; Check if at end of string, val is 0
    jz end_print_newline

    mov bh, [bp+6]  ; Load page value into bh
    int 10h         ; Call BIOS interrupt
    inc bx
    jmp print_loop_newline

  ; Print new line and carriage return values
  ; Reverse all the memory changes we made
  end_print_newline:
    mov ah, 0Eh
    mov al, 0x0d
    int 10h

    mov ah, 0Eh
    mov al, 0x0a
    int 10h
    
    pop cx
    pop bx
    mov sp, bp
    pop bp
    ret
