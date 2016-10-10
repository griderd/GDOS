all: boot

boot:
	nasm src/boot/boot.asm -f bin -o bin/boot/boot.bin
	dd if=bin/boot/boot.bin bs=512 of=mnt/boot.img
	
clean: cleandsk
	rm bin/boot/boot.bin
	
cleandsk:
	dd if=/dev/zero of=mnt/boot.img bs=512 count=2880