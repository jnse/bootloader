/**
 * Screen device and related handlers.
 */

#ifndef SCREEN_H_INCLUDE
#define SCREEN_H

#include "types.h"

/// Screen height (based on video mode set in stage2).
#define screen_rows 40
/// Screen width (based on video mode set in stage2).
#define screen_cols 80

/**
 * Represents the screen device.
 */
class screen_device
{
    /// Current cursor column.
    uint_8 m_cursor_x;
    /// Current cursor row.
    uint_8 m_cursor_y;

    public:

        /**
         * Constructor
         *
         * @param cursor_x : Column location of the cursor upon startup.
         * @param cursor_y : Row location of the cursor upon startup.
         */
        screen_device(uint_8 cursor_x, uint_8 cursor_y);

        /**
         * Writes a character to the screen at a specific location.
         *
         * Cursor is moved next to the printed character.
         *
         * @param character : Character to print to screen.
         * @param x : Column to print character at.
         * @param y : Row to print character at.
         * @param color : Color of character to print.
         */
        void putch(const uint_8 character, uint_8 x, uint_8 y, uint_8 color);

        /**
         * Writes a series of characters to the screen at a specific location.
         *
         * Cursor is moved next to the printed string.
         *
         * @param character : Character to print to screen.
         * @param x : Column to print character at.
         * @param y : Row to print character at.
         * @param color : Color of character to print.
         */ 
        void printstr(const char* str, uint_8 x, uint_8 y, uint_8 color);

};


#endif
