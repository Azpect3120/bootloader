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

  mov si, msg_kernel_boot_success
  call print

  call _cstart_   ; Call the externally defined `cstart_` function, linker will resolve its address during linking step

  cli             ; Disable interrupts just before halting
  hlt             ; Halt the CPU
  
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

msg_kernel_boot_success: db "Kernel has booted successfully", 0x0d, 0x0a, 0
