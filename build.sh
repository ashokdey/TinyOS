# assemble the boot file 
nasm -f bin -o boot.bin boot.asm 

# write to the boot file for the machine to make it bootable disk 
dd if=boot.bin of=machine/boot.img bs=512 count=1 conv=notrunc 