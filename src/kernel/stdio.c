#include "stdio.h"
#include "stdint.h"
#include "print.h"

void putc(char c) {
  x86_Video_WriteCharTeletype(c, 0);
}

void puts(const char* s) {
  int len = custom_strlen(s);
  x86_Video_WriteStringTeletype(s, 0);
}

void putcln(char c) {
  x86_Video_WriteCharTeletypeLine(c, 0);
}
void putsln(const char* s) {
  x86_Video_WriteStringTeletypeLine(s, 0);
}

int custom_strlen(const char* str) {
    int length = 0;
    while (str[length] != '\0') {
        length++;
    }
    return length;
}
