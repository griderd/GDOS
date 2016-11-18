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
%include "src/boot/common/drivers/video.asm"

%define Stage2Location 0x7E00			; This is the place in memory where
										; the second-stage bootloader lives.
%define Stage2Sector 2					; This is the floppy sector index
										; of the second-stage bootloader.

main:
	xor ax, ax		; clear AX
	mov ds, ax		; set the DS (data segment) register to zero (AX is zero)
	
					; The stack pointer is at SS:SP, or (SS * 0x10) + SP.
	mov ss, ax		; set the SS (stack segment) register (points to stack) to zero.
	mov sp, 0x9C00	; set the SP (stack frame pointer) register to 2000h past the code start.
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

	call ClearScreen
	mov ax, msg1
	call PrintStr
	
resetFloppy:	
	mov ah, 0		; function 0
	mov dl, 0		; drive 0 (floppy drive)
	int 0x13		; reset
	jc resetFloppy  ; if the Carry Flag (CF) is set, an error occurred
	
loadStageTwo:
	mov ah, 0x02	; INT 13h function 02h: Read Sectors into Memory
	mov al, 0x01	; Number of sectors to read
	mov bx, 0x0		
	mov es, bx		; ES:BX is the address of the memory buffer
	mov bx, 0x7E00
	mov dl, 0x0		; Drive number. Bit 7 is set for hard disk. Disk 0 is a floppy.
	mov dh, 0x0		; Drive head number
	mov cx, 0x2		; CH - lower eight bits of the cylinder number
					; CL - bits 0-5: sector number
					;      bits 6-7: upper bits of the cylinder number (HDD only)
	int 0x13		; Interrupt call 13h
	jc loadStageTwo	; If the Carry Flag is set, there was an error. Try again.
	
	; TODO: Set this as an error-counted loop with an output in case of failure

	jmp 0x0000:Stage2Location
	
	hlt
	
msg1 db 'Boot starting...', 13, 10, 0

; Fill the remaining space with zeros.
times 510-($-$$) db 0

; LEGACY BOOT SIGNATURE (0xAA55)
db 0x55
db 0xAA
	