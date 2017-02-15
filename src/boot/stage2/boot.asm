; boot.asm
; Second-stage boot file

; We're still in REAL MODE
;=========================================================================
[BITS 16]
[ORG 0x7E00]

%define EOL 13, 10, 0
									
xor ax, ax
xor bx, bx
xor cx, cx
xor dx, dx

cld
									
jmp main

%include "src/boot/common/drivers/video.asm"
%include "src/boot/stage2/gdt.asm"
%include "src/boot/common/memorymanager.asm"

; Okay, now that we're in the second stage, we can get down to business
; First we need to read the data from the FAT partition.
; Here's a helper file that tells us where the offsets of everything are.
%include "src/boot/common/filesystem/fat16helper.asm"
%include "src/boot/common/fileloader.asm"

%macro print 1
	mov ax, %1
	call PrintStr
%endmacro

main:
	mov ax, 0x0001
	call ChangeXY
	
	; Tell the user the bootloader is running
	print msg1

	print msg2_1
	; Load the root directory into memory
	call LoadRootDir 
	print msg2_2
	call LoadFAT
	
	print msg3
	mov si, kernel
	call FindFile
	cmp ax, 0
	je fileError
	
	mov bx, 0
	mov cx, Kernel
	call LoadFile
	
	jmp protectedMode
	
fileError:
	print filenotfound
	hlt

; Next we need to enter protected mode	
protectedMode:
	print msg4

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
	
	; Jump to the kernel
	jmp 08h:main32
	
	; hlt
	
msg1 db 'Stage 2 Loaded.', EOL
msg2 db 'Reading file system...', EOL
msg2_1 db 'Loading root directory...', EOL
msg2_2 db 'Loading File Allocation Table...', EOL
msg3 db 'Loading kernel...', EOL
msg4 db 'Entering protected mode...', EOL
done db ' DONE.', EOL

filenotfound db 'KERNEL.SYS not found.', EOL

kernel db 'KERNEL  SYS'

%include "src/boot/stage2/a20.asm"

%include "src/boot/stage2/kernelloader.asm"