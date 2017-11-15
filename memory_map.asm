
section .text

global stage1_stack
global stage1_code

;
;  Guaranteed-usable low memory:
;
; +------------+----------------+------------------+------------------+
; | Address    | Stage 1 usage  | Stage 2 usage    | Stage 3 usage    |
; +------------+----------------+------------------+------------------+
; | 0x00000500 |                |                  |                  |
; | ...        |                |                  |                  |
; | ~30 KiB    | Stack (30 KiB) |                  |                  |
; | ...        |                |                  |                  |
; | 0x00007C00 |----------------| Stack (30.5 KiB) |                  |
; | ...        |                |                  |                  |
; | 512 bytes  | Code (512 B)   |                  | Stack (33.5 KiB) |
; | ...        |                |                  |                  |
; | 0x00007E00 +----------------+------------------+                  |
; | ...        |                |                  |                  |
; | 2 KiB      |                | Code (2 KiB)     |                  |
; | ...        |                |                  |                  |
; | 0x00008600 +                |------------------|------------------|
; | ...        |                                   |                  |
; | 480.5 KiB  |                                   | Code (478.4 KiB) |
; | ...        |                                   |                  |
; | 0x0007FFFF |                                   |                  |
; +------------+                                   +------------------+

; Note: Stacks grow downward, so their start is the upper bound.
; When modifying these, don't forget to update:
;     * [ORG ...] lines in .asm files.
;     * linker scripts.

stage1_stack: equ 0x7BFF
stage1_code:  equ 0x7C00

stage2_stack: equ 0x7DFF
stage2_code:  equ 0x7E00

stage3_stack: equ 0x85FF
stage3_code:  equ 0x8600

