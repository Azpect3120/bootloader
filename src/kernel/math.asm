bits 16

; Loaded in memory after `_ENTRY` as defined in `kernel/linker.lnk`
section _TEXT class=CODE

global _x86_Add_Int_8
_x86_Add_Int_8:
  push bp
  mov bp, sp

  mov eax, [bp+4]
  add eax, [bp+6]

  mov sp, bp
  pop bp

  ret

