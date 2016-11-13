all: boot

# Generate an unformatted floppy image and apply the boot file to it
boot: cleandsk
	nasm src/stage1_boot/boot/boot.asm -f bin -o bin/boot/boot.bin
	dd if=bin/boot/boot.bin bs=512 of=mnt/boot.img conv=notrunc
	
# Delete files and create an unformatted floppy image
clean: cleandsk
	rm bin/boot/boot.bin
	
# Create an unformatted floppy image
cleandsk:
	dd if=/dev/zero of=mnt/boot.img bs=512 count=2880
	
debug:
	nasm src/boot/boot.asm -E -o src/boot/expanded_boot.asm
	
rebuild: clean boot
	
	