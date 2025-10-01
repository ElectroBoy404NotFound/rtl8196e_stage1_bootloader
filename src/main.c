#include "stdint.h"
#include "uart.h"

extern uint8_t __bss_start__;
extern uint8_t __bss_end__;

int cmain(void) {
    uart_putchar(0x0A);
    uart_putchar(0x0D);
    uart_putchar(0x40);
    uart_putchar(0x43);

    uart_putchar('\r');
    uart_putchar('\n');

    if(__bss_start__ != __bss_end__) {
        uart_putchar(0x40);

        uint8_t* bss = &__bss_start__;
        while (bss < &__bss_end__) {
            *bss++ = 0;
        }
    } else {
        uart_putchar(0x44);
    }

    uart_putchar('\r');
    uart_putchar('\n');

    for (unsigned char c = 0x21; c <= 0x7E; c++) {
        uart_putchar(c);
    }

    uart_putchar('\r');
    uart_putchar('\n');

    uart_printstring("Hello, World!\r\n");

    return 0;
}