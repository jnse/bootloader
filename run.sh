#!/bin/bash

qemu-system-x86_64 -no-reboot -no-shutdown -sdl -d guest_errors -drive format=raw,file=disk.img 
#qemu-system-x86_64 -sdl -fda floppy.img -boot a 
