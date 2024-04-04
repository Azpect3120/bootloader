bits 16

; Loaded in memory after `_ENTRY` as defined in `kernel/linker.lnk`
section _TEXT class=CODE

; Defines global function to print a character to the BIOS output.
; Can be called from C files if the `print.h` header is imported.
global _x86_Video_WriteCharTeletype
_x86_Video_WriteCharTeletype:
  push bp
  mov bp, sp
  push bx

  mov ah, 0x0E
  mov al, [bp+4]  ; Char to print
  mov bh, [bp+6]  ; Memory page number

  int 0x10
  
  pop bx
  mov sp, bp
  pop bp
  
  ret

global _x86_Video_ReadCharAtCursor
_x86_Video_ReadCharAtCursor:
  push bp
  mov bp, sp
  push bx

  ; Get char from position
  mov ah, 0x08
  mov bh, byte [bp+4]

  ; inp: al = 08
  ; inp: bh = display page
  ; out: ah = attribute of character
  ; out: al = character at cursor position
  int 0x10

  ; Load char into `eax` register
  movzx eax, al

  pop bx
  mov sp, bp
  pop bp

  ret
