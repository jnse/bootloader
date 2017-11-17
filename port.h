/**
 * c++ wrappers for low level port functions.
 */

#ifndef PORT_H_INCLUDE
#define PORT_H_INCLUDE

#include "types.h"

/**
 * Output byte to port.
 *
 * @param port : Port number.
 * @param data : Byte to be sent to port.
 */
void outb(uint32 port, uint8 data);

#endif
