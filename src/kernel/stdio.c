#include "stdio.h"
#include "print.h"

void putc(char c) {
  x86_Video_WriteCharTeletype(c, 0);
}

void puts(const char* s) {
  while (*s) {
    putc(*s);
    s++;
  }
}

void xputs(const char* s, int c) {
  int i = 0;
  while (i < c) {
    puts(s);
    i++;
  }
}

void putcln(char c) {
  x86_Video_WriteCharTeletypeLine(c, 0);
}
void putsln(const char* s) {}
void xputsln(const char* s, int c) {}
