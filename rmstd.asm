use16

global setmode
global putch
global gotoxy
extern main

section .data

section .text

jmp end

; FASTCALL void gotoxy(int x, int y)
gotoxy:
    ; set cursor position
    ;
    ; With a fastcall, the first argument goes into CX and
    ; the second argument goes into DX.
    ;
    ; Since the row and column (dh and dl) are both already
    ; part of the DX register, all we have to do is shift
    ; the dx bits to the left and add the CX value before
    ; calling the interrupt.
    ;
    ; int 10h ah=02h : set cursor position
    ;     bh = video page number
    ;     dh = row
    ;     dl = column
    ;
    mov ah, 0x02
    shl dx, 0x08
    add dx, cx
    int 0x10
    ret

; THISCALL void putch(char character)
putch:
    ; print character
    ;
    ; First argument gets passed in CX for thiscall's.
    ;
    ; int 10h ah=0e : 
    ;     al = character to print
    ;     bh = video page number
    ;
    mov ax, cx ; rightmost byte of ax == al
    mov ah, 0x0e
    xor bh, bh
    int 0x10
    ret

; THISCALL void setmode(char mode)
setmode:
    ; set video mode
    ;
    ; int 10h ah=00 :
    ;     al = video mode number
    ;
    xor ah,ah
    mov ax, cx ; rightmost byte of ax == al
    int 0x10
    ret

end:

