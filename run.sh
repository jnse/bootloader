#!/bin/bash

qemu-system-x86_64 -sdl -drive format=raw,file=disk.img 
#qemu-system-x86_64 -sdl -fda floppy.img -boot a 
