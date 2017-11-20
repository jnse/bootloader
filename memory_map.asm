section .text

global get_memory_map
global memmap_e_num

; Ask BIOS for a memory map using ax=e820, int15
; and store it in memory.
;
; This function is way longer than it 'could' have been...
; We're storing everyting in a buffer the size of a single entry, and
; then copying that buffer to the memory map, rather than saving directly
; in the appropriate location in the memory map. This is because some 
; BIOSes expect es:di to always be the same address after the first 
; continuation.
;
; input: EAX = physical memory address to load map into.
;
get_memory_map_e820:
    pusha
    ; save memory location, and get it's segment/offset.
    push eax
    call phys_to_seg_offs
	mov es, bx
	mov di, dx
    ; print message to screen with memory location. 
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
    ; set es:di to the buffer location.
    mov ax, cs
    mov es, ax
    mov di, e820_entry_buffer
    ; init entry loop
    xor ebx, ebx              ; Continuation, start from entry 0.
    xor bp, bp                ; entry counter
.fetch_entry:
    mov edx, SMAP             ; yes, we want a memory map (SMAP magic string).
    mov ecx, 24               ; ask for 24 bytes
    mov eax, 0xe820           ; EAX=E820 INT 15h : Query System Address Map
    int 0x15
    jc .unsupported           ; CS = "unsupported function"
    mov edx, SMAP             ; Some BIOSes trash edx.
    cmp eax, edx              ; eax=="SMAP" on success.
    jne .failed
.verify_entry:
    ; Skip zero-length entries.
    mov ecx, dword [es:di + 8]
    or ecx, dword [es:di + 12]
    jz .done_processing_entry
    ; Skip reserved blocks.
    mov ecx, dword [es:di + 16]
    cmp ecx, 2
    je .done_processing_entry
.save_entry:
    ; set up DS:SI to point to entry buffer.
    mov ax, cs
    mov ds, ax
    mov si, e820_entry_buffer
    ; EAX = current entry * size of entry
    push ebx             ; save ebx before clobbering
    mov eax, ebp         ; ax = current entry
    mov bx, 24           ; bx = size of entry
    mul bx               ; DX:AX = AX * BX
    ; Add this to the entry table memory offset.
    mov edx, eax
    pop ebx  ; restore clobbered ebx
    pop eax  ; pop previously saved entry table memory location in eax
    push eax ; and save it right back to the stack.
    add eax, edx
    ; Now convert the physical memory location to an offset 
    ; and segment in es:di
    push ebx ; can't clobber ebx, we're using it as entry continuation counter.
    call phys_to_seg_offs
    mov es, bx
	mov di, dx
    pop ebx
    ; Now copy ECX bytes from [DS:SI] (buffer) --> ES:DI (memory)
    mov ecx, 24
    rep movsb
    ; set es:di back to the e820 entry buffer.
    mov ax, cs       
    mov es, ax
    mov di, e820_entry_buffer
    inc bp      ; increment entry count.
.done_processing_entry:
    cmp ebx, 0  ; check if there's more.
    je .success ; exit if not
    jmp .fetch_entry
.success:
    pop eax
    mov [memmap_e_num], bp ; store number of entries.
    popa
    clc ; CS=0 success.
    ret
.unsupported:
	mov si, unsupported_err_str
	call error
.failed:
    pop eax
    popa
    stc ; CS=1 failure.
    ret

; Buffer for a single E820 entry.
e820_entry_buffer: resd 6

; Number of entries in the table.
memmap_e_num: resd 1

; "SMAP" magic string.
SMAP: equ 0x0534D4150

; User messages.
loading_mem_map_str: db 'Loading memory map into: ', 0
unsupported_err_str: db 'BIOS AX=E820h, INT 10h returned "unsupported function"', 0


