Right now this is just some experimental code in progress to toy with the idea of a 3 stage bootloader.

* Stage1 : What gets written to the MBR, has to fit in 512 bytes, mostly just loads stage2 from disk and JMP's into it.
* Stage2 : Finalizes whatever needs done in real mode (fetch info from bios etc), loads stage3, switches to protected mode and JMP's into stage3.
* Stage3 : Kernel loading code running in protected mode.



