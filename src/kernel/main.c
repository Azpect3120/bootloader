#include "stdbool.h"
#include "stdint.h"
#include "stdio.h"

// Entry point for the C code in the OS (called from the assembly entry point)
void __cdecl cstart_() {
  putc('c');
  char c = readChar();
  putc(c);
}

