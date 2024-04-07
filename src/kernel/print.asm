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

  mov ah, 0x0e
  mov al, [bp+4]  ; Char to print
  mov bh, [bp+6]  ; Memory page number

  int 0x10
  
  pop bx
  mov sp, bp
  pop bp
  
  ret


; Defines global function to divide a 64 bit number by a 32 bit number.
global _x86_div64_32
_x86_div64_32:
  push bp
  mov bp, sp

  push bx

  mov eax, [bp+8]   ; Upper 32 bits of dividend
  mov ecx, [bp+12]  ; Full 32 bits of divisor
  xor edx, edx      ; Where the remainder will be placed
  
  div ecx           ; Divide EAX by ECX, result in EAX, remainder in EDX

  mov bx, [bp+16]   ; Upper 32 bits of quotient
  mov [bx], eax

  mov eax, [bp+4]   ; Lower 32 bits of dividend
  div ecx           ; Divide EAX by ECX, result in EAX, remainder in EDX

  mov [bx], eax
  mov bx, [bp+18]   ; Lower 32 bits of quotient
  mov [bx], edx

  pop bx

  mov sp, bp
  pop bp

  ret

