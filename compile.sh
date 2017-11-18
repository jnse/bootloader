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
CPPFLAGS="-m32 -c -Wall -Werror -I . -ffreestanding -nostdinc -nostdlib -mno-red-zone -mno-mmx -mno-sse -mno-sse2"
LDFLAGS="-melf_i386 -Tstage3.ld -nostdlib -nostdc --nmagic"
g++ $CPPFLAGS -o screen.o screen.cpp
g++ $CPPFLAGS -o port.o port.cpp
g++ $CPPFLAGS -o stage3.o stage3.cpp
ld $LDFLAGS -o stage3.elf stage3.o screen.o port.o
objcopy -R .note -R .comment -S -O binary stage3.elf stage3.img

echo -e "[CREATING DISK IMAGE]"
# Creates blank disk filled with NOP's
dd if=/dev/zero bs=512 count=10 | tr "\000" "\220" > disk.img
# Stage 1 MBR (0 - 512)
dd if=stage1.img of=disk.img bs=512 conv=notrunc
# Stage 2 (512 - 1536)
dd if=stage2.img of=disk.img bs=512 seek=1 conv=notrunc
# Stage 3 (1536 - *)
dd if=stage3.img of=disk.img bs=512 seek=5 conv=notrunc


