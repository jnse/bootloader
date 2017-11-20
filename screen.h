/**
 * Screen device and related handlers.
 */

#ifndef SCREEN_H_INCLUDE
#define SCREEN_H_INCLUDE

#include "types.h"

/// Screen height (based on video mode set in stage2).
#define screen_rows 25
/// Screen width (based on video mode set in stage2).
#define screen_cols 80

/**
 * Represents the screen device.
 */
class screen_device
{
    /// Current cursor column.
    uint8 m_cursor_x;
    /// Current cursor row.
    uint8 m_cursor_y;
    /// Current text color.
    uint8 m_text_color;
    /// Current text background color.
    uint8 m_text_background;

    public:

        /**
         * Constructor.
         **/
        screen_device();

        /**
         * Clears the screen.
         */
        void clear();

        /**
         * Set color for drawing characters.
         **/
        void set_color(uint8 color);

        /**
         * Set cursor position.
         *
         * @param x : New cursor column.
         * @param y : New cursor row.
         */
        void move_cursor(uint16 x, uint16 y);

        /**
         * Writes a character to the screen at a specific location.
         *
         * @param character : Character to print to screen.
         * @param x : Column to print character at.
         * @param y : Row to print character at.
         * @param color : Color of character to print.
         */
        void putch(
            const uint8 character, 
            int16 x, 
            int16 y, 
            uint8 bg_color, 
            uint8 fg_color);

        /**
         * Writes a series of characters to the screen at a specific location.
         *
         * @param character : Character to print to screen.
         * @param x : Column to print character at.
         * @param y : Row to print character at.
         * @param color : Color of character to print.
         * @param bgcolor : Background color of character to print.
         */ 
        void printstr(const char* str, uint16 x, uint16 y, uint8 color, uint8 bgcolor);

        /**
         * Writes a series of characters to the screen.
         *
         * This version uses the current cursor position and color.
         *
         * @param character : Character to print to screen.
         */
        void printstr(const char* str);

        /**
         * Dumps memory at location ptr to the screen.
         *
         * @param ptr : Pointer to beginning of memory to be dumped.
         * @param bytes : Number of bytes to dump.
         * @param bytes_per_line : Number of bytes per line to show.
         */
        void dump_memory(volatile uint8* ptr, uint32 bytes, uint8 bytes_per_line=24);

        /**
         * Writes an integer number to the screen.
         *
         * @param number : Number to be printed
         * @param base : (optional) Number base 
         *               eg: 2 for bin, 8 for oct, 10 for dec, 16 for hex
         * @param pad : Pad zero's to left of number (overrides base16 auto-pad).
         */
        void print_number(uint32 number, int base=10, int16 pad=-1);

};

#endif
