
#define NOINLINE __attribute__((noinline))
#define REGPARM __attribute__ ((regparm(3)))
#define NORETURN __attribute__((noreturn))
#define FASTCALL __attribute__((fastcall))
#define THISCALL __attribute__((thiscall)) 

NORETURN int main(void)
{
    // To demonstrate stage3 works, for now just rainbowpuke X'es on the screen.
    int x = 0;
    char c = 0;
	unsigned char* vga = (unsigned char*) 0x000a0000;
    for (x = 0 ; x != 0x5FFFF; ++x)
    {
        *vga++ = 'X'; 
        *vga++ = c++; 
        if (c > 16) c = 0;
	}
    while(1)
	{
		__asm__("hlt\n");
	}
}

