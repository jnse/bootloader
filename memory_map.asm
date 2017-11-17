section .text

global get_memory_map
global memmap_e_num

; Ask BIOS for a memory map using ax=e820, int15
; and store it in memory.
;
; input: EAX = physical memory address to load map into.
;
get_memory_map_e820:
    pusha
	call phys_to_seg_offs
	mov es, bx
	mov di, dx
	mov si, info_str
	call print
	mov si, loading_mem_map_str
	call print
	mov ax, es
	call print_hex_number
	mov ax, ':'
	call putch
	mov ax, di
	call println_hex_number    
	xor ebx, ebx              ; ebx must be 0 to start
    xor bp, bp                ; entry counter
    mov edx, 0x0534D4150      ; yes, we want a memory map.
    mov [es:di + 20], dword 1 ; force a valid ACPI3 entry
    mov ecx, 24               ; ask for 24 bytes
    mov eax, 0xe820           
    int 0x15
    jc .unsupported           ; CS = "unsupported function"
    mov edx, 0x0534D4150      ; check if BIOS trashed edx (some do)
    cmp eax, edx
    jne .failed
    test ebx, ebx             ; ebx=0 means list is only 1 entry long (useless)
    je .failed
    jmp .jump_in
.fetch_entry:
    mov [es:di + 20], dword 1 ; force a valid ACPI3 entry
    mov ecx, 24               ; ask for 24 bytes
    mov eax, 0xe820           ; eax and ecx get trashed on every int15h call
    int 0x15
    jc .success               ; CS = end of list.
    mov edx, 0x0534D4150      ; fix potentially trashed edx.
.jump_in:
    jcxz .skipent             ; skip 0-length entries.
    cmp cl, 20                ; got a 24 byte ACPI3 response?
    jbe .notext
    test byte [es:di+20], 1   ; is 'ignore this data' bit clear?
    je short .skipent
.notext:
    mov ecx, [es:di + 8]      ; get lower 32b of memory region length
    or ecx, [es:di + 12]      ; OR it with upper 32b to test for zero.
    jz .skipent               ; if length of the 64b entry is 0, skip it.
    inc bp                    ; inc count, move to next spot.
    add di, 24
.skipent:
    test ebx, ebx             ; ebx=0 when we're done.
    jne short .fetch_entry    ; if we're not done, grab next entry.
.success:
    popa
    mov [memmap_e_num], bp    ; store number of entries.
    clc                       ; CS=0 success.
    ret
.unsupported:
	mov si, unsupported_err_str
	call error
.failed:
    popa
    stc                       ; CS=1 failure.
    ret

loading_mem_map_str: db 'Loading memory map into: ', 0
unsupported_err_str: db 'BIOS AX=E820h, INT 10h returned "unsupported function"', 0

memmap_e_num: resb 1

