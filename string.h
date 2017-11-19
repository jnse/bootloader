#ifndef STRING_H_INCLUDE
#define STRING_H

#include "types.h"

/**
 * Calculate the length of a string.
 *
 * The strlen() function calculates the length of the string pointed to
 * by s, excluding the terminating null byte ('\0').
 *
 * @param s : Null-terminated string to get size of.
 * @return The strlen() function returns the number of characters in the string
 *         pointed to by s.
 */
size_t strlen(const char* s);

#endif

