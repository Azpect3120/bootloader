bits 16

; Loaded first in memory as defined in `kernel/linker.lnk`
section _ENTRY CLASS=CODE

; Link externally defined functions during the linking step
extern _cstart_

; Defined in `linker.lnk` as the entry point to the kernel.
; Global function which calls the `cstart_` function in the `kernel/main.c` file
global entry
entry:
  cli             ; Clear the interrupt flag which disabled interrupts during setup
  mov ax, ds      ; Move data segment (ds) to the ax register
  mov ss, ax      ; Move ax, which holds data segment (ds) to the stack segment (ss). Defines the data segment as the stack segment
  mov sp, 0       ; Initialize the stack pointer (sp)
  mov bp, sp      ; Copy the stack pointer (sp) onto the base pointer (bp)
  sti             ; Set the interrupt flag which enables the use of interrupts

  call _cstart_   ; Call the externally defined `cstart_` function, linker will resolve its address during linking step

  cli             ; Disable interrupts just before halting
  hlt             ; Halt the CPU
