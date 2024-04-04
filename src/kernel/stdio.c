#include "stdio.h"
#include "stdint.h"
#include "print.h"

// Print a character by calling the `10h (0Eh)` BIOS interrupt
void putc(char c) {
  // Assembly implementation
  x86_Video_WriteCharTeletype(c, 0);
}

// Print a string by calling the `putc` function for each character
void puts(const char* s) {
  while (*s) {
    putc(*s);
    s++;
  }
}