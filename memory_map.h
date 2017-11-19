#ifndef MEMORY_MAP_H_INCLUDE
#define MEMORY_MAP_H_INCLUDE

#include "attributes.h"
#include "types.h"
#include "screen.h"

/**
 * Memory map entry as returned by AX=E820h, INT 15h
 */
struct PACKED e820_memory_map_entry
{
    uint32 base_low;
    uint32 base_high;
    uint32 len_low;
    uint32 len_high;
    uint32 type;
    uint32 acpi;
};

/**
 * Parse memory map entries.
 *
 * @param first_entry_ptr : Pointer to the first memory map entry.
 * @param num_entries : Number of memory map entries.
 */
void parse_memory_map(screen_device& screen, e820_memory_map_entry* first_entry_ptr, uint32 num_entries);

/**
 * Dumps information about a memory map entry to the screen.
 */
void debug_memory_map_entry(screen_device& screen, e820_memory_map_entry* e);

#endif
