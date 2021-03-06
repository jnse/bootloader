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
    mov al, 0x07 ; # sectors to load
    mov cl, 0x06 ; starting sector
    mov ch, 0x00 ; cylinder 0
    mov dh, 0x00 ; head 0
    call load_code
    pop ebx
    pop edx
    cmp ax, 0
    je .success
    call halt_and_catch_fire
.success:
    ; Dump first loaded bytes to screen.
    mov si, info_str
    call print
    mov si, stage3_hexdump_str
    call print
    mov ds, bx
    mov si, dx
    ; DS:SI = memory to dump
    ; BX = number of bytes
    mov bx, 4
    call memdump
	; Get a memory map.
	xor eax, eax
	mov ds, eax
	mov si, get_mem_map_str
	call info
	mov eax, memory_map
	call get_memory_map_e820
	jnc .get_mmap_success
.get_mmap_failed:
	xor ax, ax
    mov ds, ax
	mov si, get_mem_map_err_str
	call error
	call halt_and_catch_fire
.get_mmap_success:
    mov si, get_mem_map_success_str
	call info
.get_cursor_position:
	mov ah, 0x03
	xor bh, bh
	int 0x10 ; output: DH=row DL=column
.enter_protected:
    ; Enter protected mode.
    mov ss, ax
    mov eax, cr0
    or eax, 1
    mov cr0, eax
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

%include "a20.asm"
%include "shared_functions.asm"
%include "low_memory_map.asm"
%include "memory_map.asm"
%include "memdump.asm"

; -----------------------------------------------------------------------------
; Variables
; -----------------------------------------------------------------------------

section .data

%include "shared_constants.asm"

stage2_welcome_str: db 'Start stage2.', 0
do_a20_str: db 'Enabling A20.', 0
a20_enabled_str: db 'A20 enabled.', 0
a20_error_str: db 'Failed to enable A20.', 0
gdt_installed_str: db 'GDT installed.', 0
load_str: db 'Loading stage3 from disk ', 0
enter_protected_str: db 'Enter PM.', 0
get_mem_map_str: db 'Getting memory map from BIOS.', 0
get_mem_map_err_str: db 'Could not get a memory map from BIOS.', 0
get_mem_map_success_str: db 'Got memory map from BIOS.', 0
stage3_hexdump_str: db 'Hexdump of first few loaded stage3 bytes: ', 0
seven_spaces_str: db '        ',0
stage3_jmp_str: db 'Entering protected mode and jumping into stage3 at ', 0

section .text

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

[bits 32]
protected_mode_longjump:
    ; Set up segment for stage3 code.
    sti
    mov ax, 0x10
    mov ds, ax
    mov ss, ax
    mov fs, ax
    mov es, ax
    mov gs, ax
    ; Set up stack for stage3 code (0000:FFFF)
    mov esp, 0x00007E00
    mov ebp, esp
    push dword [memmap_e_num] ; pass number of memory map entries to stage3 main()
    push dword memory_map     ; pass memory map location to stage3 main()
    push word 0x0000          ; put in a blank since cursor data is a single byte.
    push word dx              ; pass cursor data to stage3 main()
    push $+2                  ; pass return address 
    jmp stage3_code
.halt:
    cli
    hlt
    jmp .halt

