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
extern "C" FASTCALL void putch(char character, char color);
extern "C" FASTCALL void gotoxy(char x, char y);

NORETURN void main()
{
    while(1);
}

