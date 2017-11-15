/**
 * Screen device and related andlers.
 */

#include "port.h"
#include "screen.h"

// Constructor
screen_device::screen_device()
    : m_cursor_x(0), m_cursor_y(0), m_text_color(7)
{

}

void screen_device::clear()
{
    for (uint_8 x = 0; x < screen_cols; ++x)
    {
        for (uint_8 y = 0; y < screen_rows; ++y)
        {
            putch(' ', x, y, m_text_color);
        }
    }
    m_cursor_x = 0;
    m_cursor_y = 0;
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
    volatile uint_8* vga = reinterpret_cast<volatile uint_8*>(0xB8000);
    // Normalize X coordinate to maximum number of columns.
    while (x >= screen_cols) x -= screen_cols;
    // There are 2 memory locations for every cursor position (character and color).
    vga += x * 2;
    vga += y * (screen_cols * 2);
    // Write into video memory.
    *vga++ = character;
    *vga = color;
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
            move_cursor(x=0,y++);
        }
        else
        {
            putch(c, x++, y, color);
        }
        str++;
    }
}

void screen_device::printstr(const char* str)
{
    printstr(str, m_cursor_x, m_cursor_y, m_text_color);
}

