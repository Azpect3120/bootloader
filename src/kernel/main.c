#include "stdint.h"
#include "stdio.h"

// Entry point for the C code in the OS (called from the assembly entry point)
void __cdecl cstart_() {
  int i = 0;
  while (i < 10) {
    puts("Hello world! Hello world! Hello world! Hello world!");
    i++;
  }
  // putsln("Hello world!");
  // putsln("Kernel with C implimentations has booted!");
  // puts("1234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890");
}
