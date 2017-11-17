/**
 * Screen device and related handlers.
 */

#ifndef SCREEN_H_INCLUDE
#define SCREEN_H

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
        void move_cursor(uint8 x, uint8 y);

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
        void printstr(const char* str, uint8 x, uint8 y, uint8 color, uint8 bgcolor);

        /**
         * Writes a series of characters to the screen.
         *
         * This version uses the current cursor position and color.
         *
         * @param character : Character to print to screen.
         */
        void printstr(const char* str);

};

#endif
