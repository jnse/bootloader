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
    mov ax, stage2_code
    mov ss, ax
    mov bp, ax
    xor ax, ax
    mov gs, ax
    mov fs, ax
    mov es, ax
    mov ds, ax
	; Set up stack.
	mov ax, stage2_stack
    mov ss, ax
    mov bp, ax
    sti
    ; Set up GDT.
    xor ax, ax
    mov ds, ax
    cli
    lgdt [gdtr]
    ; Save boot drive passed from stage1 in DL
    mov [boot_drive], byte dl
    ; Hide cursor.
    mov ah, 0x01
    mov ch, 0x3F
    int 0x10
	; Show status message.
    mov si, stage2_welcome_str
    call info
	; Enable A20 memory lane if needed.
    call enable_a20
    ; Convert physical stage3 code address
    ; to real-mode segment and offset.
    mov eax, stage3_code
    call phys_to_seg_offs ; output: BX=segment, DX=offset
    ; Print the parsed address to screen:
    ; Print message to show where where we're loading code from/to.
    mov si, info_str          ; [INFO]
    call print
    mov si, load_str          ; loading stage 3 from disk
    call print
    xor ax, ax
    mov al, [boot_drive]      ; <disk number>
    call print_hex_number
    mov si, into_str          ; into
    call print                
    mov eax, ebx              ; <segment>
    call print_hex_number
    mov ax, ':'               ; :
    call putch
    mov eax, edx              ; <offset>
    call println_hex_number
    ; Load code from disk.
    push edx
    push ebx
    mov es, bx ; ES:BX = memory location where code is loaded.
    mov bx, dx
    mov dl, [boot_drive]
    mov al, 0x03 ; # sectors to load
    mov cl, 0x05 ; starting sector
    mov ch, 0x00 ; cylinder 0
    mov dh, 0x00 ; head 0
    call load_code
    pop ebx
    pop edx
    cmp ax, 0
    je .success
    call halt_and_catch_fire
.success:
    ; Dump first 10 loaded bytes to screen.
    mov si, info_str
    call print
    mov si, stage3_hexdump_str
    call println
    mov ds, bx
    mov si, dx
    push dx
    push bx
    ; DS:SI = memory to dump
    ; BX = number of bytes
    mov bx, 9
    call memdump
    mov si, info_str
    call print
    mov si, stage3_jmp_str
    call print

    ; Enter protected mode.
    mov eax, cr0
    or eax, 1
    mov cr0, eax

    pop bx
    pop dx
    jmp (CODE_DESC - NULL_DESC) : protected_mode_longjump

; Calculate 16 bit segment address from 32 bit physical address.
;
; INPUT: EAX = physical address.
; OUTPUT: BX = Segment address. DX = Offset address.
;
phys_to_seg_offs:
    ; eax = physical
    ; ebx = segment
    ; edx = offset
    mov ebx, 0xffff
    cmp eax, 0x000ffff0
    jl .compute_segment
    jmp .compute_offset
.compute_segment:
    mov ebx, eax
    shr ebx, 4
.compute_offset:
    push ebx
    shl ebx, 4
    mov edx, eax
    sub edx, ebx
    pop ebx
    ret

; Dump memory to screen.
;
; DS:SI = memory to dump
; BX = number of bytes
memdump:
    ; Print newline.
    pusha
    mov al, 10
    call putch
    mov al, 13
    call putch
    ; Print 7 spaces.
    push si
    mov si, seven_spaces_str
    call print
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

%include "a20.asm"
%include "shared_functions.asm"
%include "memory_map.asm"

; -----------------------------------------------------------------------------
; Variables
; -----------------------------------------------------------------------------

section .data

; GDT table
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
    Limit dw gdtr - NULL_DESC - 1 ; length of GDT
    Base dd NULL_DESC             ; base of GDT


%include "shared_constants.asm"

stage2_welcome_str: db 'Start stage2.', 0
do_a20_str: db 'Enabling A20.', 0
a20_enabled_str: db 'A20 enabled.', 0
a20_error_str: db 'Failed to enable A20.', 0
gdt_installed_str: db 'GDT installed.', 0
load_str: db 'Loading stage3 from disk ', 0
enter_protected_str: db 'Enter PM.', 0
get_mem_map_str: db 'Get memmap.', 0
get_mem_map_err_str: db 'memmap failed.', 0
stage3_hexdump_str: db 'Hexdump of first few loaded stage3 bytes: ', 0
seven_spaces_str: db '        ',0
stage3_jmp_str: db 'Entering protected mode and jumping into stage3 at ', 0

section .text

[bits 32]
protected_mode_longjump:
    mov ax, 0x10
    mov ds, ax
    mov ss, ax
    mov fs, ax
    mov es, ax
    mov gs, ax
    sti
    ; Enter stage3
    jmp stage3_code
    jmp halt_and_catch_fire

