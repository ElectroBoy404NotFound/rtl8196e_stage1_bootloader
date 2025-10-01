#include "uart.h"

void uart_putchar(char c) {
    while ((UART_LSR & (UART_LSR_THRE | UART_LSR_TEMT)) != (UART_LSR_THRE | UART_LSR_TEMT));
    *UART_BASE = ((unsigned int) c) << 24;
}

void uart_printstring(char* s) {
    while(*s != '\0')
        uart_putchar(*s++);
}