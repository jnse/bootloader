#ifndef MATH64_H_INCLUDE
#define MATH64_H_INCLUDE

#include "types.h"

/**
 * Holds a 64-bit integer by storing a
 * the high and low dwords as 32bit integers.
 **/
typedef union {
    unsigned long long value;
    struct 
    {
        uint32 high;
        uint32 low;
    };  
} uint64;

/**
 * Divides two 64 bit numbers.
 *
 * @param a : divident.
 * @param b : divider.
 * @return Returns quotient of the division.
 */
uint64 uint64_div(uint64 a, uint64 b);

#endif
