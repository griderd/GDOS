; boot.asm
; Assembly-based boot sector

; We're in REAL MODE

; Real Mode address calculation: segment * 16 + offset

; The boot sector is loaded at 0000:7C00 = 0x0000 * 16 + 0x7C00 = 0x7C00
;=========================================================================

; Setup the origin address
;[ORG 0x7C00]

;jmp main

%include "src/filesystem/fat12.asm"

%include "src/boot/video.asm"

main:
	xor ax, ax		; clear AX
	mov ds, ax		; set the DS (data segment) register to zero (AX is zero)
	mov ss, ax		; set the SS (stack segment) register (points to stack) to zero.
	mov sp, 0x9C00	; set the SP (stack frame pointer) register to 2000h past the code start.
					; Remember, the stack moves upward towards zero.
				
	cld 			; Clear direction flag (I don't know why)

	initvid: InitVideo
	
p1: PrintStr msg1
p2: PrintStr msg2

hang:
	jmp hang
	
vpos: VideoPos		; Video Position Data
msg1 db 'Boot starting...', 13, 10, 0
	
	; Fill the remaining space with zeros.
	times 510-($-$$) db 0
	
	; LEGACY BOOT SIGNATURE (0xAA55)
	db 0x55
	db 0xAA
	