
#define NOINLINE __attribute__((noinline))
#define REGPARM __attribute__ ((regparm(3)))
#define NORETURN __attribute__((noreturn))
#define FASTCALL __attribute__((fastcall))
#define THISCALL __attribute__((thiscall)) 

#include "types.h"
#include "screen.h"

/**
 * Stage 3 entry point.
 *
 * Arguments are information read from BIOS and passed from
 * real mode in stage 2 of the bootloader.
 *
 * @param cursor_x : Current column of cursor.
 * @param cursor_y : Current row of cursor.
 */
NORETURN FASTCALL int main(uint_8 cursor_x, uint_8 cursor_y)
{
    screen_device screen(cursor_x, cursor_y);
    screen.printstr("Hello from C++ !!", cursor_x, cursor_y, 2);
    // Halt execution by disabling interrupts and halting forever.
    while(1)
    {
        __asm__(
            "cli\n"
            "hlt\n"
        );
    }
}
