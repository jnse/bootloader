[BITS 16]
[ORG 0x7E00]
section .text

global main

jmp main

; -----------------------------------------------------------------------------
; Functions
; -----------------------------------------------------------------------------

main:
    ; Set up segment
    cli
    mov ax, stage2_location
    mov ss, ax
    mov bp, ax
    xor ax, ax
    mov gs, ax
    mov fs, ax
    mov es, ax
    mov ds, ax
	; Set up stack.
	mov ax, stack_location
    mov ss, ax
    mov bp, ax
    sti
    ; Save boot drive passed from stage1 in DL
    mov [boot_drive], byte dl
	; Show status message.
    mov si, stage2_welcome_str
    call info
	; Enable A20 memory lane if needed.
    call enable_a20
    ; Load kernel.
    mov si, info_str
    call print
    mov si, load_str
    call print
    xor ax, ax
    mov al, [boot_drive]
    call print_hex_number
    mov si, into_str
    call print
    mov ax, stage3_location
    call println_hex_number
    xor ax, ax
    mov es, ax
    mov bx, stage3_location
    mov dl, [boot_drive]
    mov al, 0x01            ; # sectors to load
    mov cl, 0x04            ; starting sector
    mov ch, 0x00            ; cylinder 0
    mov dh, 0x00            ; head 0
    call load_code
    cmp ax, 0
    je .success
    call halt_and_catch_fire
.success:
	; Set up GDT.
.loadGDT:
    lgdt [gdtr]
	mov si, gdt_installed_str
	call info 
.enter_protected_mode:
    cli
    pusha
    mov eax, cr0
    or al, 1
    mov cr0, eax
    popa
    jmp 0x8:protected_mode_longjump

[bits 32]
protected_mode_longjump:
    mov ax, 0x10
    mov ds, ax
    mov ss, ax
    mov fs, ax
    mov es, ax
    mov gs, ax
    jmp stage3_location

[bits 16]

; Dump memory to screen.
;
; DS:SI = memory to dump
; BX = number of bytes
memdump:
    pusha
.loop:
    push si
    dec bx
    jz .end
    mov ax, si
    call print_hex_number
    mov al, ':'
    call putch
    xor ax, ax
    pop si
    lodsb      ; loads DS:SI into AL
    push si
    push ax
    call print_hex_number
    mov al, ':'
    call putch
    pop ax
    call putch
    mov si, ' '
    call println
    pop si
    jmp .loop
.end:
    popa
    ret

%include "a20.asm"
%include "shared_functions.asm"

; -----------------------------------------------------------------------------
; Variables
; -----------------------------------------------------------------------------

gdt:
    ; NULL descriptor
    NULL_DESC:
        dd 0
        dd 0
    ; Code segment
    CODE_DESC:
        dw 0xFFFF    ; limit low
        dw 0         ; base low
        db 0         ; base middle
        db 10011010b ; access
        db 11001111b ; granularity
        db 0         ; base high
    ; Data segment
    DATA_DESC:
        dw 0xFFFF    ; data descriptor
        dw 0         ; limit low
        db 0         ; base low
        db 10010010b ; access
        db 11001111b ; granularity
        db 0         ; base high

; GDT pointer
gdtr:
    Limit dw 24         ; length of GDT
    Base dd NULL_DESC   ; base of GDT

%include "shared_constants.asm"

stage2_welcome_str: db 'Entered stage2.', 0
do_a20_str: db 'Enabling A20 line.', 0
a20_enabled_str: db 'A20 line enabled.', 0
a20_error_str: db 'Failed to enable A20 memory line.', 0
gdt_installed_str: db 'GDT installed.', 0
load_str: db 'Loading stage3 from disk ', 0
enter_protected_str: db 'Entering protected mode.', 0

; -----------------------------------------------------------------------------
; Padding
; -----------------------------------------------------------------------------

; Fill remaining sector space with nop's
times 1024-($-$$) db 0x90


