
#define NOINLINE __attribute__((noinline))
#define REGPARM __attribute__ ((regparm(3)))
#define NORETURN __attribute__((noreturn))
#define FASTCALL __attribute__((fastcall))
#define THISCALL __attribute__((thiscall)) 

#include "types.h"
#include "screen.h"

/// Stage 3 entry point.
NORETURN int main(uint16 cursor_data)
{

    screen_device screen;
    screen.set_color(10);
    //screen.clear();
    uint16 cursor_start_y = cursor_data >> 8;
    uint16 cursor_start_x = cursor_data & 0xff;
    screen.move_cursor(cursor_start_x, cursor_start_y);
    screen.printstr("Start stage3.");
    // Halt execution by disabling interrupts and halting forever.
    while(1)
    {
        __asm__(
            "cli\n"
            "hlt\n"
        );
    }
}
