/**
 * Screen device and related handlers.
 */

#include "screen.h"

// Constructor
screen_device::screen_device(uint_8 cursor_x, uint_8 cursor_y)
    : m_cursor_x(cursor_x), m_cursor_y(cursor_y)
{

}

// Writes a character to the screen at specific location.
void screen_device::putch(
    const uint_8 character, uint_8 x, uint_8 y, uint_8 color)
{
    // Declare video memory start and an offset we'll use to calculate where to
    // write data to.
    uint_16 offset = 0;
    uint_8* vga = reinterpret_cast<uint_8*>(0xB8000);
    // Normalize X coordinate to maximum number of columns.
    while (x >= screen_rows) x -= screen_rows;
    // There are 2 memory locations for every cursor position (character and color).
    offset = x * 2;
    offset += y * (screen_rows * 2);
    // Write into video memory.
    vga[offset] = character;
    vga[offset+1] = color;
}


void screen_device::printstr(
    const char* str, uint_8 x, uint_8 y, uint_8 color)
{
    while(*str != 0)
    {
        putch(*str, x++, y, color);
        str++;
    }
}

