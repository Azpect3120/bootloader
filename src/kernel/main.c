#include "stdbool.h"
#include "stdint.h"
#include "stdio.h"

// Entry point for the C code in the OS (called from the assembly entry point)
void __cdecl cstart_() {
  bool_t success = add(2, 2) == 4;
  putc(success);
  putc(1);
}

