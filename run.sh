#!/bin/bash

if [ "x$1" == "x-d" ]; then
    qemu-system-i386 -S -s -watchdog-action debug -sdl -d guest_errors -drive format=raw,file=disk.img 
else
    qemu-system-x86_64 -watchdog-action debug -sdl -d guest_errors -drive format=raw,file=disk.img 
fi
