ENTRY(_start)

SECTIONS
{
    . = 0xbfc00000;

    . = ALIGN(4);
    .init : {
        *(.init)
    }

    . = ALIGN(4);
    .text : {
        *(.text)
    }

    . = ALIGN(4);
    .data : {
        *(.data)
    }
    
    . = ALIGN(4);
    .rodata : {
        *(.rodata)
    }

    .bss : {
        __bss_start__ = .;
        *(.bss)
        *(COMMON)
        __bss_end__ = .;
    }

    . = ALIGN(4);
    _stack_top = 0x80105F68;
}
