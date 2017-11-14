
; Constants used in all or multiple bootloader stages.

stack_location:  equ 0x7C00
; If you change these, don't forget to update the linker script.
stage1_location: equ 0x7C00
stage2_location: equ 0x7E00
stage3_location: equ 0x7800

ax_str: db 'AX=', 0
info_str: db '[INFO ] ', 0
error_str: db '[ERROR] ', 0
halted_str: db 'HALT', 0
reset_str: db 'Read fail: ', 0
retry_str: db 'Retry.', 0
read_error_str: db 'Disk error.', 0
into_str: db ' into ', 0
newline_str: db 10, 13, 0

boot_drive resb 1

