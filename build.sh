# assemble the boot file 
nasm -f bin -o machine/boot.bin asm/boot.asm 
nasm -f bin -o machine/loader.bin asm/loader.asm
nasm -f bin -o machine/kernel.bin asm/kernel.asm

cd machine

# write to the boot file for the machine to make it bootable disk 
dd if=boot.bin of=boot.img bs=512 count=1 conv=notrunc 

# write loaded binary to the boot image file 
# but we will have to reserve 5 block
# and since the boot binary took 1 block of the boot image, we will seek to 1
# so that the loader can be written in the 2nd block 
dd if=loader.bin of=boot.img bs=512 count=5 seek=1 conv=notrunc 

# we want to write to 100 sectors of the boot image now 
# so the count will be 100 
# and since we have already written 1 sector for boot.bin 
# and we have written 5 sectors for the loader.bin
# we will write the kernel binary with seek = 6
dd if=kernel.bin of=boot.img bs=512 count=100 seek=6 conv=notrunc 