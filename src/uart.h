#ifndef _UART_H_
#define _UART_H_

#include "stdint.h"

#define UART_BASE ((volatile unsigned int*)0xB8002000)
#define UART_LSR (*(volatile unsigned int*)0xB8002014)
#define UART_LSR_THRE (1 << 29)
#define UART_LSR_TEMT (1 << 30)

void uart_putchar(char c);
void uart_printstring(char* s);
void uart_print_hex(uint32_t val);

#endif