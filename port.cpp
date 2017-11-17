#include "types.h"
#include "port.h"

void outb(uint32 port, uint8 data)
{
    __asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
}


