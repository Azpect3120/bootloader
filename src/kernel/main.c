#include "stdio.h"
#include "stdint.h"

// Entry point for the C code in the OS (called from the assembly entry point)
void __cdecl cstart_ () {
  // xputs("Hello world from C!\n\r", 5);
  /* putcln('H');
  putcln('E');
  putcln('L');
  putcln('L');
  putcln('O'); */

  // puts("Hello world!");
  putsln("Hello world!");
  putsln("Kernel with C implimentations has booted!");
}
