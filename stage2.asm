[BITS 16]
[ORG 0x7E00]

jmp stage2

stage2:
	; Set up stack.
	cli
	xor ax, ax
    mov ss, ax
    mov sp, 0x7C00
	sti
	; Show status message.
    mov si, stage2_welcome_str
    call info
	; Enable A20 memory lane if needed.
	call check_a20
    cmp ax, 1
	je .a20_enabled
.do_a20_bios:
    call enable_a20_bios
    call check_a20
    cmp ax, 1
    je .a20_enabled
.do_a20_keyboard:
    call enable_a20_keyboard
    xor cx, cx
    call a20_check_with_timeout
    cmp ax, 1
    je .a20_enabled
.do_a20_fast:
    call enable_a20_fast
    call a20_check_with_timeout
    cmp ax, 1
    je .a20_enabled
.a20_failed_to_enable:
    mov si, a20_error_str
    call error
    jmp halt_and_catch_fire
.a20_enabled:
    mov si, a20_enabled_str
    call info

	; Shouldn't get here.
	jmp halt_and_catch_fire

; -----------------------------------------------------------------------------
; Functions
; -----------------------------------------------------------------------------

; Checks if a20 is enabled, keeps checking if not, eventually times out.
;
; returns AX=0 on failure (timeout happened, A20 not enabled).
; returns AX=1 on success (A20 is enabled).
;
a20_check_with_timeout:
    push cx
    xor cx, cx
.loop:
    call check_a20
    cmp ax, 1
    je .enabled
    inc cx
    cmp cx, 0xFFFF
    jl .loop
    xor ax, ax
    jmp .done
.enabled:
    mov ax, 1
.done:
    pop cx
    ret

; Enables A20 line using fast method (not supported by all systems).
enable_a20_fast:
    push ax
    in al, 0x92
    test al, 2
    jnz .done
    or al, 2
    and al, 0xFE
    out 0x92, al
.done:
    pop ax
    ret

; Enables A20 line using BIOS (not supported by all systems).
;
; Sets AX=0 on success
; Sets AX=1 if not supported.
; Sets AX=2 if failed.
;
enable_a20_bios:
    ; Test A20 gate support.
    mov ax, 0x2403
    int 0x15
    jb .not_supported
    cmp ah, 0
    jnz .not_supported
    ; Get A20 gate status.
    mov ax, 0x2402
    int 0x15
    jb .failed
    cmp ah, 0
    jnz .failed
    cmp al, 1
    jz .active
    ; Activate A20.
    mov ax, 0x2401
    int 0x15
    jb .failed
    cmp ah, 0
    jnz .failed
    jmp .active
.not_supported:
    mov ax, 1
    jmp .done
.failed:
    mov ax, 2
    jmp .done
.active:
    xor ax, ax
.done:
    ret

; Enables A20 line with keyboard port commands and waiting.
;
; This is slower than the BIOS method, but the BIOS method
; is not supported by all systems.
;
enable_a20_keyboard:
    cli
    call .wait
    mov al, 0xAD
    out 0x64, al
    call .wait
    mov al, 0xD0
    out 0x64, al
    call .wait2
    in al,0x60
    push eax
    call .wait
    mov al,0xD1
    out 0x64,al
    call .wait
    pop eax
    or al,2
    out 0x60,al
    call .wait
    mov al,0xAE
    out 0x64,al
    call .wait
    sti
    ret
.wait:
    in al, 0x64
    test al, 2
    jnz .wait
    ret
.wait2:
    in al,0x64
    test al,1
    jz .wait2
    ret

; Check if a20 line is already enabled.
;
; Sets AX=0 if the a20 line is disabled (memory wraps around)
; Sets AX=1 if the a20 line is enabled (memory does not wrap around) 
check_a20:
    pushf
    push ds
    push es
    push di
    push si
    cli
    xor ax, ax
    mov es, ax
    not ax
    mov ds, ax
    mov di, 0x0500
    mov si, 0x0510
    mov al, byte [es:di]
    push ax
    mov al, byte [ds:si]
    push ax
    mov byte [es:di], 0x00
    mov byte [ds:si], 0xFF
    cmp byte [es:di], 0xFF
    pop ax
    mov byte [ds:si], al
    pop ax
    mov byte [es:di], al
    mov ax, 0
    je .done
    mov ax, 1
.done:
    pop si
    pop di
    pop es
    pop ds
    popf
    ret

%include "shared_functions.asm"

; -----------------------------------------------------------------------------
; Variables
; -----------------------------------------------------------------------------

%include "shared_constants.asm"
stage2_welcome_str: db 'Entered stage2.', 0
do_a20_str: db 'Enabling A20 line.', 0
a20_enabled_str: db 'A20 line enabled.', 0
a20_error_str: db 'Failed to enable A20 memory line.', 0

