; boot.asm
; Second-stage boot file

; We're still in REAL MODE
;=========================================================================

[BITS 16]
[ORG 0x7E00]

%define Stage1Location 0x7C00		; This is the place in memory where
									; the first stage bootloader lives.

xor ax, ax
xor bx, bx
xor cx, cx
xor dx, dx

cld
									
jmp main

%include "src/boot/common/drivers/video.asm"

main:
	mov ax, 0x0001
	call ChangeXY
	mov ax, msg1
	call PrintStr
	hlt
	
msg1 db 'Stage 2 Loaded.', 13, 10, 0
