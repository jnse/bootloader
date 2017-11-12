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

; Terminate bootloader (if we get here, that's bad).
;
halt_and_catch_fire:
    mov si, halted_str
    call error
    cli
    hlt
    jmp halt_and_catch_fire
    ret


