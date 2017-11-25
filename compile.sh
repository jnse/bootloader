set -e

echo "[CLEANING]"
rm -f *.o
rm -f *.img
rm -f *.elf

echo "[COMPILING STAGE 1]"
nasm stage1.asm -f bin -o stage1.img

echo -e "[COMPILING STAGE 2]"
nasm stage2.asm -f bin -o stage2.img

echo -e "[COMPILING STAGE 3]"

WARN_FLAGS="-Wall -Werror -Werror-implicit-function-declaration"
ARCH_FLAGS="-m32 -mno-red-zone -mno-mmx -mno-sse -mno-sse2"
LIB_FLAGS="-ffreestanding -nostdlib"
CPPFLAGS="--std=c++11 -c $WARN_FLAGS -I . $LIB_FLAGS $ARCH_FLAGS -fno-tree-scev-cprop"
LDFLAGS="-melf_i386 -Tstage3.ld --nmagic -L/usr/lib64/gcc/x86_64-pc-linux-gnu/5.4.0/32 -static"
g++ $CPPFLAGS -o string.o string.cpp
g++ $CPPFLAGS -o screen.o screen.cpp
g++ $CPPFLAGS -o port.o port.cpp
g++ $CPPFLAGS -o log.o log.cpp
g++ $CPPFLAGS -o stage3.o stage3.cpp
g++ $CPPFLAGS -o abs.o abs.cpp
g++ $CPPFLAGS -o e820_memory_map.o e820_memory_map.cpp
g++ $CPPFLAGS -o math64.o math64.cpp
ld $LDFLAGS -o stage3.elf stage3.o screen.o port.o string.o log.o e820_memory_map.o math64.o
objcopy -R .note -R .comment -S -O binary stage3.elf stage3.img

echo -e "[CREATING DISK IMAGE]"
# Creates blank disk filled with NOP's
dd if=/dev/zero bs=512 count=15 | tr "\000" "\220" > disk.img
# Stage 1 MBR (1 sec)
dd if=stage1.img of=disk.img bs=512 conv=notrunc
# Stage 2 (3 sec)
dd if=stage2.img of=disk.img bs=512 seek=1 conv=notrunc
# Stage 3 (1536 - *)
dd if=stage3.img of=disk.img bs=512 seek=5 conv=notrunc


