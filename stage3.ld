ENTRY(main);

SECTIONS
{
    . = 0x00014FFF;
    .text : AT(0x00014FFF)
    {
        _text = .;
        *(.text);
        _text_end = .;
    }
    .data :
    {
        _data = .;
        *(.data);
        *(.rodata*);
        *(COMMON)
        _data_end = .;
    }
    .bss :
    {
        _bss = .;
        *(.bss);
        _bss_end = .;
    }
    /DISCARD/ :
    {
        *(.note*);
        *(.iplt*);
        *(.igot*);
        *(.rel*);
        *(.comment);
    }
}
