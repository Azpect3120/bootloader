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
