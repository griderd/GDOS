all: boot

boot:
	nasm src/boot/boot.asm -f bin -o bin/boot/boot.bin
	dd if=bin/boot/boot.bin bs=512 of=mnt/boot.img
	
clean:
	rm bin/boot/boot.bin
	dd if=/dev/zero of=mnt/boot.img bs=512 count=2880