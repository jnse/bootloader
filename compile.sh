set -e

#nasm rmstd.asm -f elf -o rmstd.o
#g++ -c -g -Os -m16 -ffreestanding -Wall -Werror -I. -o boot.o boot.cpp
##ld -m elf_i386 -static -Tlinker.ld -nostdlib --nmagic -o boot.elf boot.o
#ld -m elf_i386 -static -Tlinker.ld -nostdlib --nmagic -o boot.elf rmstd.o boot.o
#objcopy -O binary boot.elf boot.bin

echo "[COMPILING STAGE 1]"
nasm stage1.asm -f bin -o stage1.img

echo -e "[COMPILING STAGE 2]"
nasm stage2.asm -f bin -o stage2.img

echo -e "[COMPILING STAGE 3]"
g++ -m32 -nostdinc -nostdlib -ffreestanding -c -Wall -I . -o stage3.o stage3.cpp
ld -melf_i386 -Tstage3.ld -nostdinc -nostdlib --nmagic -o stage3.elf stage3.o
objcopy -R .note -R .comment -S -O binary stage3.elf stage3.img

echo -e "[CREATING DISK IMAGE]"
dd if=/dev/zero of=disk.img bs=512 count=6
# Stage 1 MBR (0 - 512)
dd if=stage1.img of=disk.img bs=512 conv=notrunc
# Stage 2 (512 - 1536)
dd if=stage2.img of=disk.img bs=512 seek=1 conv=notrunc
# Stage 3 (1536 - *)
dd if=stage3.img of=disk.img bs=512 seek=4 conv=notrunc


