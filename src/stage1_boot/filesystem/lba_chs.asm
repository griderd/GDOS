; lba_chs.asm
; Converts Sector Index to Logical Block Addressing,
; and Logical Block Addressing to Cylinder-Head-Sector
; addressing for FAT file systems.

; THIS REQUIRES "fat16.asm"

; Converts a Sector Index to CHS for use with INT 13h
SectorToCHS:
	call SectorToLBA
	call LBAToCHS
	ret

; Converts the provided Sector Index in AX to LBA
; and stores the result in AX
SectorToLBA:	; FORMULA: LBA = (Sector - 2) * SectorsPerCluster
	sub ax, 2
	mul byte [SectorsPerCluster]
	ret
	
; Converts the LBA in AX to CHS and stores the result
; in CH, CL, and DH for use with INT 13h.
LBAToCHS:
	push ax		; Temporarily store the LBA
	xor ax, ax	; First, clear all of the registers
	xor bx, bx
	xor cx, cx
	xor dx, dx	; Make sure DX is clear for division later
				; Division by 2 bytes results in a DX:AX / src
				; Where : is concatenation
				
	; Calculate Cylinder
	; FORMULA: C = LBA / (HPC * SPT)
	mov ax, [HeadsPerCylinder]
	mul [SectorsPerTrack]
	div [sp]	; The LBA is at the top of the stack
	push ax		; Lets store the Cylinder for a while
	
	; Calculate Head
	; FORMULA: H = (LBA / SPT) mod HPC
	mov ax, [esp+2]	;Get the LBA (second on stack now)
	div [SectorsPerTrack]
	div [HeadsPerCylinder]
	push dx			; Remainder from DIV is stored in DX
					; Lets store the Head for a while
	xor dx, dx		; Clear DX for division later
					
	; Calculate Sector
	; FORMULA: S = (LBA / SPT) + 1
	mov ax, [sp+4]		; Get the LBA (third on stack now)
	div [SectorsPerTrack]
	add dx, 1		; Remainder from DIV is stored in DX
	push dx			; Lets store the Sector for a while
	
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
	
	; Lastly, the cylinder
	pop bx
	mov ch, bl	; Move the lower bits to CH
	
	; Clear BX
	xor bx, bx
	ret