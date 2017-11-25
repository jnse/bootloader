/**
 * Screen device and related handlers.
 */

#include "screen.h"
#include "string.h"

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
    const uint8 character, 
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

void screen_device::print_number(uint32 number, int base, int16 pad)
{
    int buffer_max = 65;
    char buffer[buffer_max] = {};
    char* pbuffer = buffer;
    uint8 digit_count = 0;
    if (number == 0)
    {
        buffer[0] = '0';
    }
    else
    {
        // Extract digits and convert to ascii in given base.
        while (number > 0)
        {
            char output=0;
            uint32 digit=0;
            // If we're truly dealing with a 64 bit integer
            // we won't be able to divide normally because
            // gcc won't support it in freestanding 32bit 
            // executables. It does support division by powers
            // of two.
            if (number > 0x7FFFFFFF)
            {
                switch(base)
                {
                    case 16:
                        number = number / 16;
                        //float temp = number / 16;
                        //if (temp-(int)temp!=0) continue;
                        digit = number % 16;
                        break;
                    case 8:
                        number = number / 8;
                        digit = number % 8;
                        break;
                    case 2:
                        number = number / 2;
                        digit = number % 2;
                        break;
                    default:
                        printstr("\nUnsupported base.\n");
                        return;
                        break;
                }
            }
            else
            {
                // Just cast to a 32 bit number otherwise.
                uint32 temp = number;
                digit = temp %= base;
                temp = number;
                number = temp /= base;
            }
            output='0'+digit;
            if ((base == 16) and (digit >= 10)) output='A'+(digit-10);
            *pbuffer = output;
            pbuffer++;
            digit_count++;
        }
    }
    // Do number padding.
    if (pad > 0)
    {
        pad -= digit_count;
        // Do padding into buffer.
        for (uint32 digit = 0 ; digit < static_cast<uint16>(pad) ; ++digit)
        {
            *pbuffer = '0';
            pbuffer++;
            digit_count++;
        }
    }
    for (pbuffer = buffer+strlen(buffer)+1 ;  pbuffer != buffer-1; pbuffer--)
    {
        if (*pbuffer == 0) continue;
        move_cursor(m_cursor_x, m_cursor_y);
        putch(
            *pbuffer, 
            m_cursor_x,
            m_cursor_y,
            m_text_color,
            m_text_background
        );
        m_cursor_x++;
    }
}

void screen_device::dump_memory(volatile uint8* ptr, uint32 bytes, uint8 bytes_per_line)
{
    volatile uint8* start = ptr;
    volatile uint8* end = start+bytes;
    volatile uint8* current = start;
    uint8 counter = 0;
    print_number(reinterpret_cast<uint32>(current), 16, 8);
    printstr(" : ");
    for (current = start; current != end; ++current)
    {
        print_number(*current,16,2);
        printstr(" ");
        counter++;
        if (counter >= bytes_per_line) 
        {
            counter = 0;
            printstr("\n");
            print_number(reinterpret_cast<uint32>(current), 16, 8);
            printstr(" : ");
        }
    }
}


