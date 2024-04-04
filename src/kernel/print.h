#include "stdint.h"

void __cdecl x86_Video_WriteCharTeletype(char c, uint8_t page);
void __cdecl x86_Video_WriteCharTeletypeLine(char c, uint8_t page);
void __cdecl x86_Video_WriteStringTeletype(const char* str, uint8_t page);
void __cdecl x86_Video_WriteStringTeletypeLine(const char* str, uint8_t page);
