; Constants used in all or multiple bootloader stages.

info_str: db '[INFO] ', 0
error_str: db '[ERROR] ', 0
halted_str: db 'HALT', 0
retry_str: db 'Disk reset. Retrying.', 0
read_error_str: db 'Disk read error.', 0
newline_str: db 10, 13, 0

