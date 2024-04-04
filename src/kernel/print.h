#include "stdint.h"

// Provide a function signature that can be called in other 
// C programs when this file is included. Implementation is 
// defined globally in `kernel/print.asm`.
void __cdecl x86_Video_WriteCharTeletype(char c, uint8_t page);

