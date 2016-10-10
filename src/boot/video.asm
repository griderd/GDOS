; video.asm

%macro InitVideo 0
	mov ax, 0xB800		; text video memory
	mov es, ax
%endmacro