[ORG 0x7C00]
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
    ; Set up segment.
	mov ax, stage1_code
    mov ss, ax
    mov bp, ax
    xor ax, ax
    mov gs, ax
    mov fs, ax
    mov es, ax
    mov ds, ax
    ; Set up stack.
    cli
    mov ss, ax
    mov sp, stage1_stack
    sti
    ; Set video mode, print welcome message.
    call setmode
    mov si, welcome_str
    call info
    ; Load stage 2.
    mov si, info_str
    call print
    mov si, load_str
    call print
    xor ax, ax
    mov al, [boot_drive]
    call print_hex_number
    mov si, into_str
    call print
    mov ax, stage2_code
    call println_hex_number
    xor ax, ax
    mov es, ax
    mov bx, stage2_code
    mov dl, [boot_drive]
    mov al, 0x03            ; Load 3 sectors
    mov cl, 0x02            ; starting at sector 2
    mov ch, 0x00            ; cylinder 0
    mov dh, 0x00            ; head 0
    call load_code
    cmp ax, 0
    je .success
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
    mov ax, stage2_code
    call println_hex_number
    ; do jump
    mov dl, [boot_drive]
    jmp 0:stage2_code
    ; shouldn't get here.
    jmp halt_and_catch_fire
    ret

%include "shared_functions.asm"

; -----------------------------------------------------------------------------
; Variables
; -----------------------------------------------------------------------------

welcome_str: db 'Start stage1.', 0
load_str: db 'Load stage2 @disk ', 0
success_str: db 'JMP stage2 @', 0

%include "memory_map.asm"
%include "shared_constants.asm"

; -----------------------------------------------------------------------------
; Signature
; -----------------------------------------------------------------------------

; Fill with upto 510 bytes of nop's.
;
; Added benifit: will result into a compile time error when we exeed 512 bytes
; and complain about negative times.
;
times 510-($-$$) db 0x90

; Magic bytes.
db 0x55
db 0xaa

