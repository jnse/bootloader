/**
 * Screen device and related handlers.
 */

#include "port.h"
#include "screen.h"

// Constructor
screen_device::screen_device()
    : m_cursor_x(0), m_cursor_y(0), m_text_color(7), m_text_background(0)
{

}

void screen_device::clear()
{
    for (uint8 x = 0; x < screen_cols; ++x)
    {
        for (uint8 y = 0; y < screen_rows; ++y)
        {
            putch(' ', x, y, m_text_color, m_text_background);
        }
    }
    m_cursor_x = 0;
    m_cursor_y = 0;
}

void screen_device::set_color(uint8 color)
{
    m_text_color = color;
}

// Set cursor position.
void screen_device::move_cursor(uint8 x, uint8 y)
{
    // Normalize x
    while (x >= screen_cols) 
    {
        x -= screen_cols;
        y++;
    }
    // normalize y
    if (y >= screen_rows)
    {
        y=screen_rows-1;
    }
    m_cursor_x = x;
    m_cursor_y = y;
}

// Writes a character to the screen at specific location.
void screen_device::putch(
    const uint8 character, 
    int16 x, 
    int16 y, 
    uint8 fg_color, 
    uint8 bg_color)
{
    // Normalize x,y to prevent writing outside of video RAM.
    if ( x > screen_cols) x = screen_cols;
    if ( y > screen_rows) y = screen_rows;
    // Compute attributes and write to memory.
    uint16 attrib = (bg_color << 4) | (fg_color & 0x0F);
    volatile uint16* video_memory;
    video_memory = (volatile uint16*)0xB8000 + (y * screen_cols + x);
    *video_memory = character | (attrib << 8);
}


void screen_device::printstr(
        const char* str, uint8 x, uint8 y, uint8 color, uint8 bgcolor)
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
            putch(c, x++, y, color, bgcolor);
        }
        str++;
    }
}

void screen_device::printstr(const char* str)
{
    printstr(str, m_cursor_x, m_cursor_y, m_text_color, m_text_background);
}

