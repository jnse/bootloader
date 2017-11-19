#ifndef LOG_H_INCLUDE
#define LOG_H_INCLUDE

#include "screen.h"

class log_device
{

    /// Reference to the screen device.
    screen_device& m_screen;

    public:

        /**
         * Constructor.
         *
         * @param screen : Reference to the screen device.
         */
        log_device(screen_device& screen);

        /**
         * Logs an informational message.
         *
         * @param info_string Message to be logged.
         */
        void info(const char* info_string);

        /**
         * Logs an error message.
         *
         * @param error_string Message to be logged.
         */
        void error(const char* error_string);

};

#endif
