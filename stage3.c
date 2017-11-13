#define NOINLINE __attribute__((noinline))
#define REGPARM __attribute__ ((regparm(3)))
#define NORETURN __attribute__((noreturn))
#define FASTCALL __attribute__((fastcall))
#define THISCALL __attribute__((thiscall)) 

//NORETURN 
int main()
{
	//unsigned char* vga = (unsigned char*) 0xb8000;
    //vga[0] = 'X'; 
    //vga[1] = 0x09; 
	//while(1)
	//{
	//	__asm__("hlt\n");
	//}
    return 0;
}

