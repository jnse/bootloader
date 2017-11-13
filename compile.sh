set -e

#nasm rmstd.asm -f elf -o rmstd.o
#g++ -c -g -Os -m16 -ffreestanding -Wall -Werror -I. -o boot.o boot.cpp
##ld -m elf_i386 -static -Tlinker.ld -nostdlib --nmagic -o boot.elf boot.o
#ld -m elf_i386 -static -Tlinker.ld -nostdlib --nmagic -o boot.elf rmstd.o boot.o
#objcopy -O binary boot.elf boot.bin

echo "[COMPILING STAGE 1]"
nasm stage1.asm -f bin -o stage1.img

echo -e "[COMPILING STAGE 2]"
nasm stage2.asm -f elf64 -o stage2.o

echo -e "[COMPILING STAGE 3]"
cc -m64 -masm=intel -c -Wall -Werror -I . -o stage3.o stage3.c
ld -Ttext 0x100000 -o stage3.elf stage3.o stage2.o
objcopy -R .note -R .comment -S -O binary stage3.elf stage3.img

echo -e "[CREATING DISK IMAGE]"
dd if=/dev/zero of=disk.img bs=512 count=3
# Stage 1 MBR (0 - 512)
dd if=stage1.img of=disk.img bs=512 conv=notrunc
# Stage 2 (512 - 1536)
dd if=stage2.img of=disk.img bs=512 seek=1 conv=notrunc
# Stage 3 (1536 - *)
#dd if=stage3.img of=disk.img bs=512 seek=3 conv=notrunc

