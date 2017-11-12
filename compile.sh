set -e

#nasm rmstd.asm -f elf -o rmstd.o
#g++ -c -g -Os -m16 -ffreestanding -Wall -Werror -I. -o boot.o boot.cpp
##ld -m elf_i386 -static -Tlinker.ld -nostdlib --nmagic -o boot.elf boot.o
#ld -m elf_i386 -static -Tlinker.ld -nostdlib --nmagic -o boot.elf rmstd.o boot.o
#objcopy -O binary boot.elf boot.bin

echo "[COMPILING STAGE 1]"
nasm stage1.asm -f bin -o stage1.img

echo -e "[COMPILING STAGE 2]"
nasm rmstd.asm -f elf -o rmstd.o
g++ -c -g -Os -m16 -ffreestanding -Wall -Werror -I . -o stage2.o stage2.cpp
ld -m elf_i386 -static -Tstage2.ld -nostdlib --nmagic -o stage2.elf rmstd.o stage2.o
objcopy -O binary stage2.elf stage2.img

echo -e "[CREATING DISK IMAGE]"
dd if=stage1.img of=disk.img bs=512
dd if=stage2.img of=disk.img bs=512 seek=1 conv=notrunc


