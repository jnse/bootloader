
#include "log.h"
#include "screen.h"

// Constructor.
log_device::log_device(screen_device& screen) 
    : m_screen(screen)
{

}

// Log informational message.
void log_device::info(const char* info_string)
{
    m_screen.printstr("[INFO ] ");
    m_screen.printstr(info_string);
    m_screen.printstr("\n");
}

// Log error message.
void log_device::error(const char* error_string)
{
    m_screen.printstr("[ERROR] ");
    m_screen.printstr(error_string);
    m_screen.printstr("\n");
}

