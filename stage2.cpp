__asm__(".code16gcc\n");
__asm__(
    "mov %ax, 0x13\n"
    "int $0x10\n"
);
__asm__ ("jmpl  $0, $main\n");

#define NOINLINE __attribute__((noinline))
#define REGPARM __attribute__ ((regparm(3)))
#define NORETURN __attribute__((noreturn))
#define FASTCALL __attribute__((fastcall))
#define THISCALL __attribute__((thiscall)) 

extern "C" THISCALL void setmode(char mode);
extern "C" THISCALL void putch(char character);
extern "C" FASTCALL void gotoxy(char x, char y);

char output_color=7;

class screen_device
{

    /// Whether or not we're currently in a video text mode or not.
    /// (If in graphics mode, we need to render fonts with blitting pixels).
    bool m_text_mode;

    /// Whether to use bios (int10h) calls to render text or not.
    /// (If not, write directly to video memory).
    bool m_use_bios;

    /// How many characters fit in a row of text in the current mode.
    char m_screen_width;

    /// Cursor column.
    char m_cursor_x;

    /// Cursor row.
    char m_cursor_y;

    public:

        screen_device(char mode, bool use_bios=true) : 
            m_text_mode(true), 
            m_use_bios(use_bios),
            m_cursor_x(0),
            m_cursor_y(0)
        {
            setmode(mode);
            if ((mode > 3) and (mode != 7)) m_text_mode=false;
            if (m_text_mode == true)
            {
                if (mode < 2) 
                {
                    m_screen_width = 40;
                }
                else
                {
                    m_screen_width = 80;
                }
            }
        }

        void print(const char* text)
        {
            if (m_text_mode == true)
            {
                if (m_use_bios == true)
                {
         
                    while (*text != 0)
                    {
                        if (*text == '\n')
                        {
                            m_cursor_x=0;
                            m_cursor_y++;
                            continue;
                        }
                        putch(*text++);
                        m_cursor_x++;
                        if (m_cursor_x > m_screen_width)
                        {
                            m_cursor_x=0;
                            m_cursor_y++;
                        }
                        gotoxy(m_cursor_x, m_cursor_y);
                    }
                }
            }
        }
};

/*
void print(const char* string)
{
    volatile char* video = (volatile char*) 0xB8000;
    while (*string != 0)
    {
        *video++ = *string++;
        *video++ = output_color;
    }
}
*/

NORETURN void main()
{
    screen_device screen(2);
	screen.print("Hello\nWorld");
    while(1);
}


