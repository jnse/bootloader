#include "e820_memory_map.h"
#include "screen.h"

// Parse memory map entries.
void parse_memory_map(screen_device& screen, e820_memory_map_entry* first_entry_ptr, uint32 num_entries)
{
    e820_memory_map_entry* entry = first_entry_ptr;
    for (uint32 ne = 0 ; ne != num_entries; ++ne)
    {
        debug_memory_map_entry(screen, entry);
        entry += 1;
        screen.printstr("\n");
    }
}

// Dumps information about a memory map entry to the screen.
void debug_memory_map_entry(screen_device& screen, e820_memory_map_entry* e)
{
    if (!e) return;

    screen.printstr("base: ");
    screen.print_number(e->base_high, 16, 8);
    screen.print_number(e->base_low, 16, 8); 
    screen.printstr(" length: ");
    screen.print_number(e->len_high, 16, 8);
    screen.print_number(e->len_low, 16, 8);
    screen.printstr(" type: ");
    switch(e->type)
    {
        case 1:
            screen.printstr("FREE");
            break;
        case 2:
            screen.printstr("RESERVED");
            break;
        default:
            screen.printstr("UNDEFINED");
            break;
    }
}

