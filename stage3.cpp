
#define NOINLINE __attribute__((noinline))
#define REGPARM __attribute__ ((regparm(3)))
#define NORETURN __attribute__((noreturn))
#define FASTCALL __attribute__((fastcall))
#define THISCALL __attribute__((thiscall)) 

#include "types.h"
#include "screen.h"

/// Stage 3 entry point.
NORETURN int main()
{
    const char hello[] = "Hello from c++!!\0";
    screen_device screen(0,22);
    screen.set_color(10);
    screen.printstr(hello);
    //screen.printstr("Just testing.\n\0");
    // Halt execution by disabling interrupts and halting forever.
    while(1)
    {
        __asm__(
            "cli\n"
            "hlt\n"
        );
    }
}
