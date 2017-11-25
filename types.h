/**
 * Defines shorthand typedefs for commonly used types.
 */

#ifndef TYPES_H_INCLUDE
#define TYPES_H_INCLUDE

/// Unsigned 8 bit integer.
typedef unsigned char uint8;
/// Unsigned 16 bit integer.
typedef unsigned short uint16;
/// Unsigned 32 bit integer.
typedef unsigned int uint32;
/// Signed 8 bit integer.
typedef char int8;
/// Signed 16 bit integer.
typedef short int16;
/// Signed 32 bit integer.
typedef int int32;
/// Signed 64 bit integer.
typedef decltype(sizeof(0)) size_t;

#endif

