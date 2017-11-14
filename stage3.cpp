
#define NOINLINE __attribute__((noinline))
#define REGPARM __attribute__ ((regparm(3)))
#define NORETURN __attribute__((noreturn))
#define FASTCALL __attribute__((fastcall))
#define THISCALL __attribute__((thiscall)) 

#define screen_rows 80

typedef unsigned char u8;
typedef unsigned short u16;
typedef unsigned int u32;

void putch(u8 character, u8 x, u8 y, u8 color);
void printstr(const char* str, u8 x, u8 y, u8 color);

NORETURN FASTCALL int main(u8 cursor_x, u8 cursor_y)
{
    // To demonstrate stage3 works, for now just rainbowpuke X'es on the screen.
    printstr("Hello from C++ !!", cursor_x, cursor_y, 2);
    while(1)
	{
		__asm__(
            "cli\n"
            "hlt\n"
        );
	}
}

void putch(u8 character, u8 x, u8 y, u8 color)
{
    // Declare video memory start and an offset we'll use to calculate where to
    // write data to.
    u16 offset = 0;
	u8* vga = (u8*) 0xB8000;
    // Normalize X coordinate to maximum number of columns.
    while (x >= screen_rows) x -= screen_rows;
    // There are 2 memory locations for every cursor position (character and color).
    offset = x * 2;
    offset += y * (screen_rows * 2);
    // Write into video memory.
    vga[offset] = character;
    vga[offset+1] = color;
}

void printstr(const char* str, u8 x, u8 y, u8 color)
{
    while(*str != 0)
    {
        putch(*str, x++, y, color);
        str++;
    }
}

