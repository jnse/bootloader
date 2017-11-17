
#define NOINLINE __attribute__((noinline))
#define REGPARM __attribute__ ((regparm(3)))
#define NORETURN __attribute__((noreturn))
#define FASTCALL __attribute__((fastcall))
#define THISCALL __attribute__((thiscall)) 

#include "types.h"
#include "screen.h"

/// Stage 3 entry point.
NORETURN THISCALL int main(uint16 cursor_data)
{

    screen_device screen;

    screen.set_color(7);
    screen.clear();

    uint8 cursor_start_x = 0;
    uint8 cursor_start_y = 11;
    //screen.move_cursor(cursor_start_x, cursor_start_y);
    if (cursor_data==0) 
    {
        screen.printstr("cursor data is zero");
    }
    else
    {
        screen.printstr("got cursor data");
    }
    // Halt execution by disabling interrupts and halting forever.
    while(1)
    {
        __asm__(
            "cli\n"
            "hlt\n"
        );
    }
}
