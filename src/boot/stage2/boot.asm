; boot.asm
; Second-stage boot file

; We're still in REAL MODE
;=========================================================================
[BITS 16]
[ORG 0x7E00]

%define Stage1Location 0x7C00		; This is the place in memory where
									; the first stage bootloader lives.
%define EOL 13, 10, 0
									
xor ax, ax
xor bx, bx
xor cx, cx
xor dx, dx

cld
									
jmp main

%include "src/boot/common/drivers/video.asm"
%include "src/boot/stage2/gdt.asm"

%macro print 1
	mov ax, %1
	call PrintStr
%endmacro

main:
	mov ax, 0x0001
	call ChangeXY
	
	; Tell the user the bootloader is running
	print msg1
	
	; Enable A20
	call a20_enable
	
	; Clear interrupts
	cli
	
	; Load the GDT
	lgdt [gdt_ptr]
	
	; Enter protected mode
	mov eax, cr0		; Load the control register
	or al, 1			; Set the Protection Enabled bit
	mov cr0, eax		; Send it back
	
	jmp 08h:stage3_main
	
hold:
	jmp hold
	
hlt
	
msg1 db 'Stage 2 Loaded.', EOL
msg2 db 'Ready to load kernel.', EOL

%include "src/boot/stage2/a20.asm"

; We're still in Protected Mode!
;=========================================================================
[BITS 32]

stage3_main:
	mov ax, 0x10
	mov ds, ax
	mov ss, ax
	mov es, ax
	mov esp, 0x90000
	
stop:
	cli
	hlt