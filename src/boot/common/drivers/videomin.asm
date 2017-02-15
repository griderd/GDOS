; video.asm
; VGA mode 3 video driver.
; Provides minimal video support

; Prints a string to the screen using video memory
; Parameter: string to print

ClearScreen:
	mov byte[xpos], 0
	mov byte[ypos], 0
	mov ax, 0xB800			; text video memory
	mov es, ax
	mov ax, 0x20
	mov bx, 0
	
.loop:
	push bx
	call printc
	pop bx
	inc bx
	cmp bx, 2000
	jl .loop
	mov byte[xpos], 0
	mov byte[ypos], 0
	ret

; Prints a string to the screen
; Arguments:
;	AX: Value
; NOTE: Make sure you pusha before using the function!
PrintStr:
	mov si, ax
	mov ax, 0xB800			; text video memory
	mov es, ax
	xor ax, ax
	call prints
	ret
	
prints:
	pusha					; push the registers onto the stack
	call print_s			; print the string
	popa					; pop the registers from the stack
	ret

dochar:
	call printc
print_s:
	lodsb					; first char to AL and increment SI
	
checkLF:
	cmp al, 0x0A
	jne checkCL
	call print_LF
	jmp print_s

checkCL:
	cmp al, 0x0D
	jne checkEOL
	call print_CR
	jmp print_s
	
checkEOL:
	cmp al, 0				; compare to null terminator
	jne dochar				; if not null, print. otherwise, exit loop
	ret
	
printc:
	mov ah, 0x07			; Set the color attribute (attribute goes in AH, character is in AL) to white on black
	mov cx, ax				; save char/attribute to CX
	
	; Calculate the Y-Position memory offset
	movzx ax, byte [ypos]	; get the current y-position and put it in AX
	mov dx, 160				; 80 columns x 2 bytes per character/attribute
	mul dx					; multiply the y-position by 160 and store it in EAX
	
	; Calculate the X-Position memory offset.
	movzx bx, byte [xpos]	; get the current x-position
	shl bx, 1				; multiply by two (shift left 1 bit) to get rid of the attribute
	
	; Add the offsets and store it in the Destination Index register (destination pointer of stream operations)
	mov di, 0				; set offset to zero
	add di, ax				; add the y-offset
	add di, bx				; add the x-offset
	
	mov ax, cx				; restore the char/attribute to AX
	stosw					; write character from AX to the address in DI (Destination Index) and increment DI
	add byte [xpos], 1
	
	; Okay, now we're going to make this code a little safer by checking that we're not overrunning the end of the line.
	cmp byte[xpos], 80		; if we're at the end of the line
	jne printc_end
	
	call print_NewLine
printc_end:
	ret
	
print_NewLine:
	call print_LF
	call print_CR
	ret
	
print_LF:
	add byte [ypos], 1	; move one row down
	ret
	
print_CR:
	mov byte[xpos], 0	; move to the beginning of the line
	ret

; Change the X-Y screen writing position to the value at AX, where AH is X and AL is Y
ChangeXY:
	mov byte[xpos], ah
	mov byte[ypos], al
	ret
	
	
;%macro VideoPos 0
xpos db 0
ypos db 0
spc db ' '
;%endmacro