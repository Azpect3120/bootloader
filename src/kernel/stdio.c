#include "stdio.h"
#include "math.h"
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
    x86_Video_WriteCharTeletype(*s, 0);
    s++;
  }
}

int add(int a, int b) {
  int8_t sum = x86_Add_Int_8(a, b);
  return sum;
}

