
; Constants used in all or multiple bootloader stages.

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

