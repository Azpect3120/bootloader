#include "stdbool.h"
#include "stdint.h"
#include "stdio.h"

// Entry point for the C code in the OS (called from the assembly entry point)
void __cdecl cstart_() {
  puts("main.c has been loaded successfully\r\n");
  print_f("Formatted: %% %c %s\r\n", 'f', "Hello");
}
