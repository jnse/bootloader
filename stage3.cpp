// Make sure that the first instruction is stage3 is a jmp into main.
__asm__("jmp main");

#include "attributes.h"
#include "types.h"
#include "screen.h"
#include "log.h"
#include "e820_memory_map.h"
#include "math64.h"

/// Halts the CPU.
NORETURN void halt(log_device& log)
{
    log.error("HALT");
    while(1)
    {
        __asm__(
            "cli\n"
            "hlt\n"
        );
    }
}

/// Stage 3 entry point.
NORETURN int main(uint16 cursor_data, e820_memory_map_entry* memmap_ptr, uint32 memmap_entries)
{
    screen_device screen;
    log_device log(screen);
    // Set cursor position to the one passed from stage2.
    uint16 cursor_start_y = cursor_data >> 8;
    uint16 cursor_start_x = cursor_data & 0xff;
    screen.move_cursor(cursor_start_x, cursor_start_y);
    // Log welcome message.
    log.info("Start stage3.");
    // Check memory map entries.
    if (memmap_entries == 0)
    {
        // Memory map is useless.
        log.error("No memory map entries returned by BIOS.");
        halt(log);
    }
    // Parse memory map entries.
    screen.printstr("\nMemory map : \n");
    parse_memory_map(screen, memmap_ptr, memmap_entries);
    // Halt execution by disabling interrupts and halting forever.
    while(1)
    {
        __asm__(
            "cli\n"
            "hlt\n"
        );
    }
}
