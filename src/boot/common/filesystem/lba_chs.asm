; lba_chs.asmdi
; Converts Sector Index to Logical Block Addressing,
; and Logical Block Addressing to Cylinder-Head-Sector
; addressing for FAT file systems.

; THIS REQUIRES "fat16.asm"

; Converts a Sector Index to CHS for use with INT 13h
SectorToCHS:
	;call SectorToLBA
	call LBAToCHS
	ret

; Converts the provided Sector Index in AX to LBA
; and stores the result in AX
SectorToLBA:	; FORMULA: LBA = (Sector - 2) * SectorsPerCluster
	sub ax, 2
	mov bl, SectorsPerCluster
	mul bl
	ret

; LBA is in AX
; LBA is in AX
LBAToCHS:
	push ax			; store LBA
	
	; clear registers
	xor ax, ax
	xor bx, bx
	xor cx, cx
	xor dx, dx
	
	; Cylinder = LBA / (HeadsPerCylinder * SectorsPerTrack)
	mov ax, word [HeadsPerCylinder]
	mov bx, word [SectorsPerTrack]
	mul bx
	xor dx, dx			; Clear any overflow
	mov bx, ax			; (HPC * SPT) is the bottom number, move to bx
	mov ax, word [esp]	; Get the LBA
	div bx				; Divides LBA by (HPC * SPT)
	xor dx, dx
	push ax				; Push the Cylinder onto the stack
	
	; Calculate Temp
	; FORMULA: T = LBA % (HPC * SPT)
	mov ax, word [HeadsPerCylinder]
	mov bx, word [SectorsPerTrack]
	mul bx
	xor dx, dx
	mov ax, word [esp+2]
	div bx
	push dx				; Push the temp value onto the stack
	
	; Calculate Head
	; FORMULA: H = T / SPC
	mov ax, dx		; Get the temp value
	mov bx, word [SectorsPerTrack]
	xor dx, dx
	div bx
	push ax				; Push the Head onto the stack 
	
	; Calculate Sector
	; FORMULA: S = T % SPC + 1
	mov ax, word [esp+2]
	mov bx, word [SectorsPerTrack]
	div bx
	inc dx
	push dx
	
	; OK, all of the calculations are finished.
	; It's time to arrange the data so that it'll
	; be in a format acceptable for INT 13h:
	
	; CH: lower byte of cylinder number
	; CL: sector number (bits 0-5) and high-bits of cylinder (bits 6-7 (HDD only))
	; DH: Head number
	
	; NOTE: We're going to assume this is a floppy drive so we're ignoring 
	; CL bits 6-7 and setting them to 0.
	
	; First, clear all of the registers
	xor ax, ax
	xor bx, bx
	xor cx, cx
	xor dx, dx
	
	; Let's start with the sector
	pop cx		; Pop the sector number off the stack
				; and put it in CX. The lower bits
				; should contain the sector number
	
	; Next, the Head
	pop dx
	mov dh, dl	; Put the head in DH. DL will contain the drive number
	xor dl, dl	; Clear DL for the drive number
	
	; Next, get rid of the division number
	pop ax
	
	; Lastly, the cylinder
	pop bx
	mov ch, bl	; Move the lower bits to CH
	
	; Remove the LBA from the stack
	pop ax
	xor ax, ax
	xor bx, bx
	ret