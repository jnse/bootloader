
section .text

global stage1_stack
global stage1_code
global stage2_stack
global stage2_code
global memory_map

;
;  Guaranteed-usable low memory:
;
; +------------+--------------------+------------------+------------------+
; | Address    | Stage 1 usage     | Stage 2 usage    | Stage 3 usage    |
; +------------+-------------------+------------------+------------------+
; | 0x00000500 |                   |                  |                  |
; | ...        |                   |                  | Stack            |
; | 12.25 KiB  |                   |                  | (90.74 KiB)      |
; | ...        |                   |                  |                  |
; | 0x00003600 |                   |                  |                  |
; | ...        |                   |                  |                  |
; | 17.5KiB    | Stack (29.75 KiB) |                  |                  |
; | ...        |                   |                  |                  |
; | 0x00007C00 |-------------------| Stack (30.9 KiB) |                  |
; | ...        |                   |                  |                  |
; | 512 bytes  | Code (512 B)      |                  |                  |
; | ...        |                   |                  |                  |
; | 0x00007E00 +-------------------+------------------+                  |
; | ...        |                   |                  |                  |
; | 2 KiB      |                   | Code (2 KiB)     |                  |
; | ...        |                   |                  |                  |
; | 0x00016FFF +                   |                  +------------------+
; | ...        |                   |                  | Memory map       |
; | 20 KiB     |                   |                  | (20 KiB)         |
; | ...        |                   |                  |                  |
; | 0x0000FFFF +                   +------------------+------------------|
; | ...        |                                      |                  |
; | 400 KiB    |                                      | Code (400 KiB)   |
; | ...        |                                      |                  |
; | 0x0007FFFF |                                      |                  |
; +------------+                                      +------------------+

; Note: Stacks grow downward, so their start is the upper bound.
; When modifying these, don't forget to update:
;     * [ORG ...] lines in .asm files.
;     * linker scripts.

stage1_stack: equ 0x7BFF
stage1_code:  equ 0x7C00

stage2_stack: equ 0x7DFF
stage2_code:  equ 0x7E00
stage3_stack: equ 0x0001BFFE
stage3_code:  equ 0x0001BFFF

memory_map:   equ 0x00016FFF

