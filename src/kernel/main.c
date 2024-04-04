#include "stdio.h"
#include "stdint.h"

// Entry point for the C code in the OS (called from the assembly entry point)
void __cdecl cstart_ () {
  puts("Hello world from C!");
}
