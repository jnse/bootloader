
extern pgdt
extern kernel_main
global load_gdt

load_gdt:
	lgdt [pgdt]
	cli
	pusha
    mov eax, cr0
    or al, 1
    mov cr0, eax
	popa
	sti
	jmp 0x08:complete_flush

bits 32
complete_flush:
    mov ax, 0x10
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax
    jmp stage3_location

