# assemble the boot file 
nasm -f bin -o machine/boot.bin boot.asm 
nasm -f bin -o machine/loader.bin loader.asm

cd machine

# write to the boot file for the machine to make it bootable disk 
dd if=boot.bin of=boot.img bs=512 count=1 conv=notrunc 

# write loaded binary to the boot image file 
# but we will have to reserve 5 block
# and since the boot binary took 1 block of the boot image, we will seek to 1
# so that the loader can be written in the 2nd block 
dd if=loader.bin of=boot.img bs=512 count=5 seek=1 conv=notrunc 