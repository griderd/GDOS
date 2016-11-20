#$(eval stage1Size = $(shell stat --printf="%s" bin/boot/boot.bin))
#@echo boot.bin is $(stage1Size) bytes long

all: clearscreen boot

clearscreen:
	@clear

# Generate an unformatted floppy image and apply the boot file to it
boot: cleandsk
	@echo Assembling boot sector...
	@nasm src/boot/stage1/boot.asm -f bin -o bin/boot/boot.bin
	@echo Applying boot sector to disk...
	@dd if=bin/boot/boot.bin bs=512 of=mnt/boot.img conv=notrunc status=none
	@echo Assembling second-stage bootloader...
	@nasm src/boot/stage2/boot.asm -f bin -o bin/boot/boot.sys
	@echo Applying second-stage bootloader to disk...
	@dd if=bin/boot/boot.sys bs=512 seek=1 of=mnt/boot.img conv=notrunc status=none
	@echo Done.
	@echo
	@ls bin -l -R
	
# Delete files and create an unformatted floppy image
clean: cleandsk
	@echo Deleting binaries...
	@rm bin/boot/boot.bin
	@rm bin/boot/boot.sys
	@echo Done.
	
# Create an unformatted floppy image
cleandsk:
	@echo Generating a 1440 KB floppy disk...
	@dd if=/dev/zero of=mnt/boot.img bs=512 count=2880 status=none
	@echo Done.
	
debug:
	nasm src/boot/stage1/boot.asm -E -o src/boot/expanded_boot.asm
	nasm src/boot/stage2/boot.asm -E -o src/boot/expanded_boot2.asm
	
rebuild: clean boot
	
stat:
	@ls bin -l -R