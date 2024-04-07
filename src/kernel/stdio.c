#include "stdio.h"
#include "math.h"
#include "stdbool.h"
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

void puts_f(const char far* s) {
  while (*s) {
    putc(*s);
    s++;
  }
}


void print_f(const char* fmt, ...) {
  int* arg_ptr = (int*) &fmt;
  int state = PRINTF_STATE_START;
  int length = PRINTF_LENGTH_START;
  int radix = 10;
  bool_t sign = false;

  arg_ptr++;
  while (*fmt) {
    switch (state) {
      case PRINTF_STATE_START:
        if (*fmt == '%') {
          state = PRINTF_STATE_LENGTH;
        } else {
          putc(*fmt);
        }
        break;
      case PRINTF_STATE_LENGTH:
        if (*fmt == 'h') {
          length = PRINTF_LENGTH_SHORT;
          state = PRINTF_STATE_SHORT;
        } else if (*fmt == 'l') {
          length = PRINTF_LENGTH_LONG;
          state = PRINTF_STATE_LONG;
        } else {
          goto PRINTF_STATE_SPEC_;
        }
        break;
      case PRINTF_STATE_SHORT:
        if (*fmt == 'h') {
          length = PRINTF_LENGTH_SHORT_SHORT;
          state = PRINTF_STATE_SPEC;
        } else {
          goto PRINTF_STATE_SPEC_;
        }
        break;
      case PRINTF_STATE_LONG:
        if (*fmt == 'l') {
          length = PRINTF_LENGTH_LONG_LONG;
          state = PRINTF_STATE_SPEC;
        } else {
          goto PRINTF_STATE_SPEC_;
        }
        break;
      case PRINTF_STAET_SPEC:
      PRINTF_STATE_SPEC_:
        switch (*fmt) {
          // Character
          case 'c':
            putc((char) *arg_ptr);
            arg_ptr++;
            break;
          // String
          case 's':
            if (length == PRINTF_LENGTH_LONG || length == PRINTF_LENGTH_LONG_LONG) {
              puts_f(*(const char far**)arg_ptr);
              arg_ptr += 2;
            } else {
              puts(*(const char**)arg_ptr);
              arg_ptr++;
            }
            break;
          // Escape the percent sign
          case '%':
            putc('%');
            break;
          // Integer
          case 'd':
          case 'i':
            radix = 10;
            sign = true;
            arg_ptr = printf_number(arg_ptr, length, sign, radix);
            break;
          // Unsigned integer
          case 'u':
            radix = 10;
            sign = false;
            arg_ptr = printf_number(arg_ptr, length, sign, radix);
            break;
          // Hexadecimal
          case 'X':
          case 'x':
          case 'p':
            radix = 16;
            sign = false;
            arg_ptr = printf_number(arg_ptr, length, sign, radix);
            break;
          // Octal
          case 'o':
            radix = 8;
            sign = false;
            arg_ptr = printf_number(arg_ptr, length, sign, radix);
            break;
          // Other
          default:
            break;
        }
        state = PRINTF_STATE_START;
        length = PRINTF_LENGTH_START;
        radix = 10;
        sign = false;
        break;
    }
    fmt++;
  }
}

const char possibleChars[] = "0123456789abcdef";

int * printf_number(int* arg_ptr, int length, bool_t sign, int radix) {
  char buffer[32];
  unsigned long long number;
  int number_sign = 1;
  int pos = 0;
  
  switch (length) {
    case PRINTF_LENGTH_SHORT_SHORT:
    case PRINTF_LENGTH_SHORT:
    case PRINTF_LENGTH_START:
      if (sign) {
        int n = *arg_ptr;
        if (n < 0) {
          n = -n;
          number_sign = -1;
        }
        number = (unsigned long long) n;
      } else {
        number = *(unsigned int*)arg_ptr;
      }
      arg_ptr++;
      break;
    case PRINTF_LENGTH_LONG:
      if (sign) {
        long int n = *(long int*)arg_ptr;
        if (n < 0) {
          n = -n;
          number_sign = -1;
        }
        number = (unsigned long long) n;
      } else {
        number = *(unsigned long int*)arg_ptr;
      }
      arg_ptr += 2;
      break;
    case PRINTF_LENGTH_LONG_LONG:
      if (sign) {
        long long int n = *(long long int*)arg_ptr;
        if (n < 0) {
          n = -n;
          number_sign = -1;
        }
        number = (unsigned long long) n;
      } else {
        number = *(unsigned long long int*)arg_ptr;
      }
      arg_ptr += 4;
      break;
  }

  do {
    uint32_t rem;
    x86_div64_32(number, radix, &number, &rem);
    buffer[pos++] = possibleChars[rem];
  } while (number > 0);

  // Add sign if needed
  if (sign && number_sign < 0) {
    buffer[pos++] = '-';
  }

  // Print the number
  while (--pos >= 0) {
    putc(buffer[pos]);
  }
}




int add(int a, int b) {
  int8_t sum = x86_Add_Int_8(a, b);
  return sum;
}

