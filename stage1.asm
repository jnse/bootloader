[ORG 0x7c00]
[BITS 16]

jmp stage1

; -----------------------------------------------------------------------------
; Functions
; -----------------------------------------------------------------------------

; Entry point for stage1 bootloader.
;
stage1:
    ; BIOS sets boot drive in the dl register, save it.
    mov [boot_drive], dl
    ; Initialize registers.
    xor ax, ax
    mov ds, ax
    mov es, ax
    ; Set up stack.
    cli
    mov ss, ax
    mov sp, 0x7C00
    sti
    ; Set video mode, print welcome message.
    call setmode
    mov si, welcome_str
    call info
    ; Load stage 2.
    call load_stage2
    jnc .success            ; if carry flag is set, disk read failed.
    ; On error print message and halt.
    mov si, read_error_str
    call error
    jmp halt_and_catch_fire
.success:
    ; On success show message with jump address.
    mov si, info_str
    call print
    mov si, success_str
    call print
    mov ax, stage2_location
    call println_hex_number
    ; do jump
    jmp stage2_location
    ; shouldn't get here.
    jmp halt_and_catch_fire
    ret

; Print number.
;
; AX = number to print.
;
print_number:
    ; save clobbered registers.
    pusha
    ; if number is a single digit, just print it.
    cmp ax, 10
    jl .print_single
    ; Count digits in CX.
    xor cx, cx
    ; otherwise keep dividing digit by 10 
    ; and extract individual digits from the remainder.
.loop:
    inc cx
    ; divide number by 10
    xor dx, dx
    mov bx, 10
    div bx
    ; extracted digit is in dx, push it on the stack.
    push dx
    ; when number is 0, we're done.
    test ax, ax
    jz .print_stack
    jmp .loop
.print_stack:
    pop ax
    add ax, '0'
    call putch
    dec cx
    jz .done
    jmp .print_stack
.print_single:
    add ax, '0'
    call putch
.done:
    popa
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

; Load stage2 from disk into memory.
load_stage2:
    pusha
    ; Print information
    mov si, info_str
    call print
    mov si, load_str
    call print
    xor ax, ax
    mov al, [boot_drive]
    call println_hex_number
    mov cx, 3                 ; attempts
.read_sectors:
    push cx
    ; Memory location. (ES:BX)
    xor ax, ax
    mov es, ax
    mov bx, stage2_location   
    ; Disk location.
    mov al, 0x01              ; load 1 sector
    mov ch, 0x00              ; cylinder
    mov cl, 0x02              ; sector
    mov dh, 0x00              ; head
    mov dl, byte [boot_drive] ; as saved from bios.
    mov ah, 0x02              ; int 13h, ah=02h : read sectors into memory
    int 0x13
    pop cx
    jnc .success              ; exit on success
.reset:
    mov si, retry_str
    call error
    dec cx
    cmp cx, 0
    jle .giveup               ; give up when at max attempts
    xor ah,ah                 ; int 13h, ah=00h : reset disk
    int 0x13
    jnc .read_sectors         ; if reset worked, try again
.success:
    clc
    jmp .done
.giveup:
    stc
.done:
    popa
    ret

; Sets video mode to 80 columns.
; (also clears screen)
;
setmode:
    pusha
    xor ah,ah
    mov ax, 0x07
    int 0x10
    popa
    ret

%include "shared_functions.asm"

; -----------------------------------------------------------------------------
; Variables
; -----------------------------------------------------------------------------

; Where in memory to load stage2 from disk.
stage2_location: equ 0x7E00
welcome_str: db 'Entered stage1.', 0
load_str: db 'Load stage1 from disk ', 0
success_str: db 'Jump to stage2 at ', 0
%include "shared_constants.asm"
boot_drive resw 0

; -----------------------------------------------------------------------------
; Signature
; -----------------------------------------------------------------------------

; fill with upto 510 bytes of nop's
times 510-($-$$) db 0x90

; magic bytes
db 0x55
db 0xaa

