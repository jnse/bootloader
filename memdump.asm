%ifndef MEMDUMP_H_INCLUDE
%define MEMDUMP_H_INCLUDE

; Dump memory to screen.
;
; DS:SI = memory to dump
; BX = number of bytes
memdump:
    pusha
    push si
    ; Print segment:offset
    pop si
    mov ax, ds
    call print_hex_number
    mov al, ':'
    call putch
    mov ax, si
    call print_hex_number
    mov al, ' '
    call putch
.loop:
    push si
    dec bx
    jz .end
    xor ax, ax
    pop si
    lodsb      ; loads DS:SI into AL
    push si
    cmp ax, 0x0F
    jle .pad
    jmp .donepad
.pad:
    push ax
    mov ax, '0'
    call putch
    pop ax
.donepad:
    call print_hex_number
    mov al, ' '
    call putch
    pop si
    jmp .loop
.end:
    mov al, 10
    call putch
    mov al, 13
    call putch
    pop si
    popa
    ret

%endif

