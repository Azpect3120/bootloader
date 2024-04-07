#include "stdint.h"

// Provide a function signature that can be called in other 
// C programs when this file is included. Implementation is 
// defined globally in `kernel/print.asm`.
void __cdecl x86_Video_WriteCharTeletype(char c, uint8_t page);

void __cdecl x86_div64_32(uint64_t dividend, uint32_t divisor, uint64_t* quotient, uint32_t* remainder);
