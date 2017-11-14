/**
 * Screen device and related handlers.
 */

#include "port.h"
#include "screen.h"

// Constructor
screen_device::screen_device(uint_8 cursor_x, uint_8 cursor_y)
    : m_cursor_x(cursor_x), m_cursor_y(cursor_y), m_text_color(7)
{

}

void screen_device::set_color(uint_8 color)
{
    m_text_color = color;
}

// Set cursor position.
void screen_device::move_cursor(uint_8 x, uint_8 y)
{
    // Normalize x
    while (x > screen_cols) 
    {
        x -= screen_cols;
        y++;
    }
    m_cursor_x = x;
    m_cursor_y = y;
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
    move_cursor(x,y);
}


void screen_device::printstr(
    const char* str, uint_8 x, uint_8 y, uint_8 color)
{
    // Print string by iterating characters until null-terminator.
    char c = 1;
    while(c != 0) 
    {
        c = *str;
        // Handle newlines.
        if ((c == 10) or (c == 13))
        {
            move_cursor(x,y++);
        }
        putch(c, x++, y, color);
        str++;
    }
}

void screen_device::printstr(const char* str)
{
    printstr(str, m_cursor_x, m_cursor_y, m_text_color);
}



