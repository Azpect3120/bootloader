#include "stdint.h"
#include "stdio.h"

// Entry point for the C code in the OS (called from the assembly entry point)
void __cdecl cstart_() {
  int i = 0;
  while (i < 10) {
    puts("Hello world!\r\n");
    i++;
  }
}