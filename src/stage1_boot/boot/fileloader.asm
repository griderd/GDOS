; fileloader.asm
; Loads files from the FAT16 file system.

;===================================================================
;| Boot Sector | Reserved | FAT 1 | FAT 2 | Root Dir | Data Region |
;===================================================================

; THIS REQUIRES "fat16.asm"

%include "src/stage1_boot/drivers/floppy.asm"

; Loads the root diretory
; The root directory is located immediately after the FAT
; Be sure to reset the floppy first!
LoadRootDir:
	xor ax, ax	; clear ax
	
	call floppyReset

	; Calculate the position of the root directory
	mov al, [NumberOfFATs]		; gets the number of FAT tables
	mul [SectorsPerFat]			; multiplies it by the number of sectors per FAT
	add ax, [Reserved]			; Adds the number of reserved sectors
	; AX now contains the sector number location of the root directory
	
	push 0						; Data buffer segment
	push 0x9C00					; Data buffer offset
	push 1						; Number of sectors to read (one for the directory)
	push ax						; Sector index to read
	call floppyReadCluster
	
	; TODO: Check status value in AH. If AH = 0x11, AL is burst length
	; CF is clear if successful. Otherwise CF is set. 
	; If Successful, AL contains the number of sectors transfered. 
	
; Finds a file whose name is a string pointed to by SI
FindFile:
	
