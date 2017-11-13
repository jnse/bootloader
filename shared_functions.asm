; Functions used in all or multiple bootloader stages.

; Write character to screen.
;
; AX = character
;
putch:
    pusha
    mov ah, 0x0E
    mov bx, 0x0007
    int 0x10
    popa
    ret

; Prints text to the screen using bios calls.
;
; DS:SI == ptr to string
;
print:
    pusha
.loop:
    lodsb           ; al = [ds:si]++
    test al, al     ; exit when null terminator
    jz .end         ; encountered.
    call putch
    jmp .loop
.end:
    popa
    ret

; Prints a string and starts a new line.
;
; DS:SI == ptr to string
;
println:
    pusha
    call print
    mov si, newline_str
    call print
    popa
    ret

; Prints an error message.
;
; DS;SI == ptr to error message string.
;
error:
    pusha
    push si
    mov si, error_str
    call print
    pop si
    call println
    popa
    ret

; Prints an info message.
;
; DS:SI == ptr to error message string.
;
info:
    pusha
    push si
    mov si, info_str
    call print
    pop si
    call println
    popa
    ret

; Sets video mode to 80 columns.
; (also clears screen)
;
setmode:
    push ax
    mov ax, 0x03
    int 0x10
    pop ax
    ret

; Print number as hex.
;
; AX = number to print.
;
print_hex_number:
    ; save clobbered registers.
    pusha
    push ax
    mov al, '0'
    call putch
    mov al, 'x'
    call putch
    pop ax
    ; Count digits in CX.
    xor cx, cx
    ; otherwise keep dividing digit by 10 
    ; and extract individual digits from the remainder.
.loop:
    inc cx
    ; divide number by 16
    xor dx, dx
    mov bx, 16
    div bx
    ; extracted digit is in dx, push it on the stack.
    push dx
    ; when number is 0, we're done.
    test ax, ax
    jz .print_stack
    jmp .loop
.print_stack:
    pop ax
    cmp ax, 10
    jge .letter
    add ax, '0'
    jmp .doprint
.letter:
    sub ax, 10
    add ax, 'A'
.doprint:
    call putch
    dec cx
    jz .done
    jmp .print_stack
.done:
    popa
    ret

; same as print_hex_number but start a new line.
println_hex_number:
    pusha
    call print_hex_number
    mov si, newline_str
    call print
    popa
    ret

; Load code from disk into memory.
;
; CL = sector start
; AL = number of sectors
; DH = head
; CH = cylinder
; DL = drive
; ES:BX = memory location
;
; Return: AX=0 success
;         AX!=0, AH=return code, AL actual sectors read count.
load_code:
    push si
    mov si, 0x0a              ; attempts
.read_sectors:
    ; Disk location.
    mov ah, 0x02              ; int 13h, ah=02h : read sectors into memory
    int 0x13
    jnc .success              ; exit on success
.reset:
    push si
    push ax
    mov si, error_str
    call print
    mov si, reset_str
    call print
    mov si, ax_str
    call print
    pop ax
    call println_hex_number
    pop si
    dec si
    cmp si, 0
    jle .giveup               ; give up when at max attempts
    xor ah,ah                 ; int 13h, ah=00h : reset disk
    int 0x13
    push si
    mov si, retry_str
    call info
    pop si
    jnc .read_sectors         ; if reset worked, try again
.success:
    xor ax, ax
    jmp .done
.giveup:
.done:
    pop si
    ret

; Terminate bootloader (if we get here, that's bad).
;
halt_and_catch_fire:
    mov si, halted_str
    call error
    cli
    hlt
    jmp halt_and_catch_fire
    ret

