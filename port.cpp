#include "types.h"
#include "port.h"

void outb(uint_32 port, uint_8 data)
{
    __asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
}


