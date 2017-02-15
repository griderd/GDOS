; kernelloader.asm
; Kernel loader

[BITS 32]

main32:

	mov ax, 0x10
	mov ds, ax
	mov ss, ax
	mov es, ax
	mov esp, 90000h

stop:
	cli
	hlt