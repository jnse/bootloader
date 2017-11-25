#include "math64.h"

// Divides two 64 bit numbers.
uint64 uint64_div(uint64 a, uint64 b)
{
    uint64 result = {};
    // If a and b fit in uint32's we can do
    // straight up division.
    if (a.high == 0 and b.high == 0
        and a.low <= 0x7FFFFFFF 
        and b.low <= 0x7FFFFFFF)
    {
        result.low = a.low / b.low;
        return result;
    }

    return result;
}
