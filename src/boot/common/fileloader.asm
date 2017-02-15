; fileloader.asm
; Loads files from the FAT16 file system.

;===================================================================
;| Boot Sector | Reserved | FAT 1 | FAT 2 | Root Dir | Data Region |
;===================================================================

; THIS REQUIRES "fat16.asm" or "fat16helper.asm"

%include "src/boot/common/drivers/floppy.asm"

; Loads the root directory sector by index located in AX
; Due to limited space, we're only examining one sector at a time
; The root directory is located immediately after the FAT
LoadRootDir:
	xor ax, ax	; clear ax
	xor dx, dx	; Clear DX also. 
	
	call floppyReset

	; Calculate the position of the root directory
	mov al, byte [NumberOfFATs]		; gets the number of FAT tables
	mov bx, word [SectorsPerFat]
	mul bx							; multiplies it by the number of sectors per FAT
	mov bx, word [ReservedSectors]
	add ax, bx						; Adds the number of reserved sectors
	; AX now contains the sector number location of the root directory
	
	push 0						; Data buffer segment
	push RootDir				; Data buffer offset
	push RootDirSectors			; Number of sectors to read (32)
	push ax						; Sector index to read
	call floppyReadCluster
	pop ax
	pop ax
	pop ax
	pop ax
	xor ax, ax
	
	ret
	
	; TODO: Check status value in AH. If AH = 0x11, AL is burst length
	; CF is clear if successful. Otherwise CF is set. 
	; If Successful, AL contains the number of sectors transfered. 
	
; Loads the primary File Allocation Table from the disk and stores it in 0x9d00
LoadFAT:
	xor ax, ax
	xor dx, dx
	
	call floppyReset
	
	mov ax, word [ReservedSectors]
	
	push 0				; Data buffer segment
	push FileTable		; Data buffer offset
	mov bx, word [SectorsPerFat]	; Number of sectors to read
	push bx
	xor bx, bx
	push ax
	call floppyReadCluster
	pop ax
	pop ax
	pop ax
	pop ax
	xor ax, ax
	
	ret

; Finds a file whose name is a string pointed to by SI and stores the starting cluster ID in AX
; If the result of AX is 0, the function failed to find the file
; Registers:
; AL/AH - storing characters from each string
; BX - Counting charaters
; CX - Counting entries
; DX - Storing the working DI
FindFile:
	push si
	
	mov bx, 0
	mov cx, 0

	; Set DI to the location of the root directory
	mov di, RootDir
	mov dx, di
	
.start:
	; Get the characters
	mov al, byte [di]
	mov ah, byte [si]
	
	; Compare them
	cmp al, ah
	
	je .cont
	jne .nextEntry
	
.cont:
	inc bx
	cmp bx, 11
	je .success		; If we've reached the last character, get the cluster ID and exit
	
.nextchar:
	inc si
	inc di
	jmp .start
	
.nextEntry:
	; Go to the next entry
	inc cx
	
	cmp cx, 512
	je .fail
	
	mov bx, 32		; each entry is 32 bytes long
	add dx, bx		; Add 32 to the original DI offset
	mov si, [esp]	; Move the new offset to SI...
	mov di, dx		; ... and DI
	
	mov bx, 0	; reset the characer counter
	jmp .start
	
.success:
	; Get the starting cluster ID and put it in AX
	pop ax
	mov bx, 26
	add dx, bx
	mov di, dx
	mov ax, word [di]
	ret
	
.fail:
	pop ax
	mov ax, 0
	ret

; Loads the file whose first cluster is located in AX into the provided buffer
; The buffer offset is BX:CX	
LoadFile:
	call floppyReset
	
	; Position SI at the start of the FAT in memory
	mov si, FileTable
	
	; Increment SI until it reaches the cluster indicated by AX
	.checkClusterID:
		cmp si, ax
		je .checkCluster
		inc si
		jmp .checkClusterID
		
	; Check that the cluster is not EOF
	.checkCluster:
		cmp ax, 0xFFF8
		jge .endOfFile

	.loadCluster:
		push bx		; Data buffer segment
		push cx		; Data buffer offset
		push 1		; Sectors to read
		push ax		; Sector index to read
		
		call floppyReadCluster		; Read the cluster
		
		; Okay, now we'll get the next cluster from the FAT
		inc si
		mov ax, [si]
		
		jmp .checkCluster
		
	.endOfFile:
		ret
		