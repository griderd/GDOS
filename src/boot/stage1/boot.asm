; boot.asm
; Assembly-based boot sector

; We're in REAL MODE
;=========================================================================

;=========================================================================
; Print a string using PrintStr.	
;p1: PrintStr msg1

; Print a hexadecimal number using PrintHex
;p2: PrintHex ax

; Print a new line by calling print_NewLine
;call print_NewLine
;=========================================================================

%include "src/boot/common/filesystem/fat16.asm"
%include "src/boot/common/drivers/videomin.asm"
%include "src/boot/common/drivers/floppy.asm"
%include "src/boot/common/memorymanager.asm"

%define Stage2Sector 1					; This is the floppy sector index
										; of the second-stage bootloader.

main:
	xor ax, ax		; clear AX
	mov ds, ax		; set the DS (data segment) register to zero (AX is zero)
	
					; The stack pointer is at SS:SP, or (SS * 0x10) + SP.
	mov ss, ax		; set the SS (stack segment) register (points to stack) to zero.
	mov sp, Stack	; set the SP (stack frame pointer) register to 2000h past the code start.
					; Remember, the stack moves upward towards zero.
					; We should probably set the second-stage bootloader to load
					; at 0000:7E00, which is right behind the stack.
				
	cld 			; Clear DI (Direction) Flag.
					; This sets up Auto-Incrementing Mode so that stream processing
					; on the SI (Source Index) and DI (Destination Index) registers
					; increment when using auto-incrementing instructions like LODSB.
					; The opposite mode, auto-decrementing, decrements the SI and DI
					; registers when using LODSB. We're going to be printing strings,
					; whose pointer address is at the beginning of the string. We
					; need the SI and DI registers to increment instead of decrement.

	; Okay, clear the screen (in Bochs, the screen doesn't clear before
	; handing control to the bootloader) and then print my message
	call ClearScreen
	mov ax, msg1
	call PrintStr

	; Reset the floppy disk to read from the first sector
	call floppyReset
	
	; Load the sectors into memory
	push 0x0				; buffer segment
	push Stage2Boot			; buffer offset
	push 2					; Sectors to read
	push Stage2Sector		; Sector index to read
	call floppyReadCluster

	; Jump to the beginning of the second-stage loader
	jmp 0x0000:Stage2Boot
	
msg1 db 'Boot starting...', 13, 10, 0

; Fill the remaining space with zeros.
times 510-($-$$) db 0

; LEGACY BOOT SIGNATURE (0xAA55)
db 0x55
db 0xAA
	