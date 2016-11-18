; print.asm
; Performs real-mode BIOS-supported printing

%macro BiosPrint 1
	mov si, word %1
	
ch_loop:
	lodsb
	or al, al
	jz done
	mov ah, 0x0E
	int 0x10
	jmp ch_loop
	
done:
	ret
%endmacro