set disassembly-flavor intel
set architecture i8086
target remote localhost:1234
break *0x7E00
display/i $pc
continue
