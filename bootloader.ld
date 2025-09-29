ENTRY(_start)

SECTIONS
{
    . = 0xbfc00000;

    .text : {
        *(.text)       /* Keep all text sections */
    }
}
