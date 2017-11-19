#include "memory_map.h"
#include "screen.h"

// Parse memory map entries.
void parse_memory_map(screen_device& screen, e820_memory_map_entry* first_entry_ptr, uint32 num_entries)
{
    e820_memory_map_entry* entry = first_entry_ptr;
    for (uint32 ne = 0 ; ne != num_entries; ++ne)
    {
        debug_memory_map_entry(screen, entry);
        entry += sizeof(e820_memory_map_entry);
        screen.printstr("\n");
    }
}

// Dumps information about a memory map entry to the screen.
void debug_memory_map_entry(screen_device& screen, e820_memory_map_entry* e)
{
    if (!e) return;
    screen.printstr("base: 0x");
    screen.print_number(e->base_high, 16, 8);
    screen.print_number(e->base_low, 16, 8);
    screen.printstr(" len: 0x");
    screen.print_number(e->len_high, 16, 8);
    screen.print_number(e->len_low, 16, 8);
    screen.printstr(" type: 0x");
    screen.print_number(e->type, 16);
    screen.printstr(" acpi: 0x");
    screen.print_number(e->acpi, 16);
}

