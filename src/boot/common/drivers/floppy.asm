; floppy.asm
; Floppy disk driver

; REQUIRES "fat16.asm"

%include "src/boot/common/filesystem/lba_chs.asm"

; Resets the floppy disk to read from sector 0
floppyReset:
	mov ah, 0		; function 0
	mov dl, 0		; drive 0 (floppy drive)
	int 0x13		; reset
	jc floppyReset  ; if the Carry Flag (CF) is set, an error occurred
	ret

		
; Reads the provided number of sectors into memory
; Arguments:
;	1. Data buffer segment
;   2. Data buffer offset
;	3. Number of sectors to read
;	4. Sector index to read
floppyReadCluster:	
	mov di, 5		; Set an error counter
	
	.check:
		cmp di, 0		; Check the error counter
		je .end		; If it's zero, return an error
	
	.start:
		;pop ax			; Get the sector index to read
		mov ax, word [esp+2]
		call SectorToCHS

		;pop ax			; Get the number of sectors to read from AL
		mov ax, word [esp+4]
		mov ah, 0x02	; Function 2: Read sectors into memory
		
		;pop bx			; Get the buffer offset
		mov bx, word [esp+8]
		;pop es			; Get the buffer segment
		mov ax, word [esp+10]
		
		int 0x13		; Read the data
		
		dec di			; Count down the error counter
		jc .check		; If the CF (carry flag) has been set, there
						; was an error reading the floppy.
						; <Zoidberg> Try again, maybe? </Zoidberg>
	
	.end:
		ret