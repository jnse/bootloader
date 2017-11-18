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
void screen_device::move_cursor(uint16 x, uint16 y)
{
    // Normalize x
    while (x > screen_cols) 
    {
        x -= screen_cols;
        y++;
    }
    // normalize y
    if (y > screen_rows) y=screen_rows;
    m_cursor_x = x;
    m_cursor_y = y;
}

// Writes a character to the screen at specific location.
void screen_device::putch(
    uint8 character, 
    int16 x, 
    int16 y, 
    uint8 fg_color, 
    uint8 bg_color)
{
    // Don't print null characters.
    if (character==0) return;
    // Handle newlines.
    if ((character == 10) or (character==13))
    {
        move_cursor(0,y+1);
        return;
    }
    // Normalize x,y to prevent writing outside of video RAM.
    if ( x >= screen_cols) x = screen_cols-1;
    if ( y >= screen_rows) y = screen_rows-1;
    // Compute attributes and write to memory.
    uint16 attrib = (bg_color << 4) | (fg_color & 0x0F);
    volatile uint16* video_memory;
    video_memory = (volatile uint16*)0xB8000 + (y * screen_cols + x);
    *video_memory = character | (attrib << 8);
    move_cursor(x,y);
}


void screen_device::printstr(
        const char* str, uint16 x, uint16 y, uint8 color, uint8 bgcolor)
{
    // Print string by iterating characters until null-terminator.
    while (*str != 0)
    {
        move_cursor(m_cursor_x, m_cursor_y);
        putch(*str, m_cursor_x, m_cursor_y, color, bgcolor);
        if ((*str != 10) and (*str != 13)) m_cursor_x++;
        str++;
    }
}

void screen_device::printstr(const char* str)
{
    printstr(str, m_cursor_x, m_cursor_y, m_text_color, m_text_background);
}

void screen_device::print_number(int number, int base)
{
    char buffer[32] = {};
    char* pbuffer = buffer;
    char digit_count=0;
    int original_number = number;
    // Extract digits and convert to ascii in given base.
    while (number > 0)
    {
        char output=0;
        int digit = number % base;
        number = number / base;
        output='0'+digit;
        if ((base == 16) and (digit >= 10)) output='A'+(digit-10);
        *pbuffer = output;
        pbuffer++;
        digit_count++;
    }
    // If we're printing hex digits, pad the output to 8, 16, or 32 bits.
    if (base == 16)
    {
        char pad=0;
        // Handle padding for 8 and 16 bit hex numbers.
        // 0xF becomes 0x0F and 0xFFF becomes 0x0FFF
        if (
            (original_number < 0x10) 
            or ((original_number > 0xFF) and (original_number < 0x1000)))
        {
            pad = 1;
        }
        else if (original_number > 0xFFFF) // Pad to 32bit if >16bit number.
        {
            pad = 8 - digit_count;
        }
        // Do padding into buffer.
        for (int digit = 0 ; digit < pad ; ++digit)
        {
            *pbuffer = '0';
            pbuffer++;
            digit_count++;
        }
    }
    // Traverse buffer in reverse and print to screen.
    for (int digit = digit_count; digit >= 0; --digit)
    {
        if (buffer[digit] != 0)
        {
            move_cursor(m_cursor_x, m_cursor_y);
            putch(
                buffer[digit], 
                m_cursor_x,
                m_cursor_y,
                m_text_color,
                m_text_background
            );
            m_cursor_x++;
        }
    }
}

