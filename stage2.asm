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
    ; Get memory map.
    call get_memory_map
    ; Load stage3 from disk.
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
    mov al, 0x02            ; # sectors to load
    mov cl, 0x05            ; starting sector
    mov ch, 0x00            ; cylinder 0
    mov dh, 0x00            ; head 0
    call load_code
    cmp ax, 0
    je .success
    call halt_and_catch_fire
.success:
    ; Dump first 10 loaded bytes to screen.
    mov si, info_str
    call print
    mov si, stage3_hexdump_str
    call print
    ; DS:SI = memory to dump
    ; BX = number of bytes
    mov ax, stage3_location
    mov si, ax
    mov bx, 9
    call memdump
	; Set up GDT.
.loadGDT:
    lgdt [gdtr]
	mov si, gdt_installed_str
	call info
.enter_protected_mode:
    mov si, info_str
    call print
    mov si, stage3_jmp_str
    call print
    mov ax, stage3_location
    call println_hex_number
    xor ah, ah
    cli
    pusha
    mov eax, cr0
    or al, 1
    mov cr0, eax
    popa
    jmp 0x8:protected_mode_longjump

; Get a memory map of the system so we know where we can load stuff.
get_memory_map:
    pusha
    mov si, get_mem_map_str
    call info
    xor bx, bx              ; continuation (set to 0 for first call)
    xor dx, dx              ; ES:DI buffer ptr to hold result table.
    mov es, dx              ; We'll just overwrite stage1 with the table.
    mov di, stage1_location
    mov cx, 512             ; buffer size
    ; Signature: 'SMAP'
    ; BIOS wants this set to verify that we really want it 
    ; to return a map.
    mov dx, 'SMAP'
    ; int 15h ax=E820 : Query system address map.
    mov ax, 0xE820
    int 0x15
    jnc .done
.error:
    mov si, get_mem_map_err_str
    call error
.done:
    popa
    ret

[bits 32]
protected_mode_longjump:
    mov ax, 0x10
    mov ds, ax
    mov ss, ax
    mov fs, ax
    mov es, ax
    mov gs, ax
    jmp stage3_location
.halter:
    hlt
    jmp .halter

[bits 16]

; Dump memory to screen.
;
; DS:SI = memory to dump
; BX = number of bytes
memdump:
    pusha
    mov al, 10
    call putch
    mov al, 13
    call putch
    push si
    mov si, seven_spaces_str
    call print
    pop si
    mov ax, si
    call print_hex_number
    mov al, ':'
    call putch
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

; -----------------------------------------------------------------------------
; Variables
; -----------------------------------------------------------------------------

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
    Limit dw 24         ; length of GDT
    Base dd NULL_DESC   ; base of GDT

%include "shared_constants.asm"

stage2_welcome_str: db 'Start stage2.', 0
do_a20_str: db 'Enabling A20.', 0
a20_enabled_str: db 'A20 enabled.', 0
a20_error_str: db 'Failed to enable A20.', 0
gdt_installed_str: db 'GDT installed.', 0
load_str: db 'Loading stage3 ', 0
enter_protected_str: db 'Enter PM.', 0
get_mem_map_str: db 'Get memmap.', 0
get_mem_map_err_str: db 'memmap failed.', 0
stage3_hexdump_str: db 'Hexdump of first few loaded stage3 bytes: ', 0
seven_spaces_str: db '        ',0
stage3_jmp_str: db 'Entering protected mode and jumping into stage3 at ', 0

; -----------------------------------------------------------------------------
; Padding
; -----------------------------------------------------------------------------

; Fill remaining sector space with nop's
times 2048-($-$$) db 0x90


