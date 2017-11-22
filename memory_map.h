#ifndef MEMORY_MAP_H_INCLUDE
#define MEMORY_MAP_H_INCLUDE

#include "attributes.h"
#include "types.h"
#include "screen.h"

struct memory_map_entry
{
    uint32 start_high;
    uint32 start_low;
    uint32 end_high;
    uint32 end_low;
};


#endif
