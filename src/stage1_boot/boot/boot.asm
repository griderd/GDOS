; boot.asm
; Assembly-based boot sector

; We're in REAL MODE
;=========================================================================

%include "src/stage1_boot/filesystem/fat16.asm"
%include "src/stage1_boot/drivers/video.asm"

main:
	xor ax, ax		; clear AX
	mov ds, ax		; set the DS (data segment) register to zero (AX is zero)
	
					; The stack pointer is at SS:SP, or (SS * 0x10) + SP.
	mov ss, ax		; set the SS (stack segment) register (points to stack) to zero.
	mov sp, 0x9BFF	; set the SP (stack frame pointer) register to 1FFFh past the code start.
					; Remember, the stack moves upward towards zero.
					; We should probably set the second-stage bootloader to load
					; at 0000:9C00, which is right behind the stack.
				
	cld 			; Clear DI (Direction) Flag.
					; This sets up Auto-Incrementing Mode so that stream processing
					; on the SI (Source Index) and DI (Destination Index) registers
					; increment when using auto-incrementing instructions like LODSB.
					; The opposite mode, auto-decrementing, decrements the SI and DI
					; registers when using LODSB. We're going to be printing strings,
					; whose pointer address is at the beginning of the string. We
					; need the SI and DI registers to increment instead of decrement.
	
p1: PrintStr msg1

p2: PrintStr msg2

mov ax, 0x0123
mov bx, 0xDEF0

p3: PrintHex ax
call print_NewLine
p4: PrintStr msg3
p5: PrintHex bx
call print_NewLine

hang:
	jmp hang
	
vpos: VideoPos		; Video Position Data
msg1 db 'Boot starting...', 13, 10, 0
msg2 db 'AX: ', 0
msg3 db 'BX: ', 0

	
	; Fill the remaining space with zeros.
	times 510-($-$$) db 0
	
	; LEGACY BOOT SIGNATURE (0xAA55)
	db 0x55
	db 0xAA
	