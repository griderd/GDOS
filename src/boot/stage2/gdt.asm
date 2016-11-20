; gdt.asm
; This contains the actual table

; Each descriptor must be 8 bits long

gdt:
; null descriptor
	dd 0
	dd 0
	
; code descriptor:
	dw 0xFFFF		; segment limit, low
	dw 0			; segment base address, low
	db 0			; segment base address, middle
	db 10011010b	; access byte
	db 11001111b	; granularity byte. Lower nibble is segment limit high bits
	db 0			; segment base address, high
	
; data descriptor
	dw 0xFFFF		; segment limit, low
	dw 0			; segment base address, low
	db 0			; segment base address, middle
	db 10010010b	; access byte
	db 11001111b	; granularity byte. Lower nibble is segment limit high bits
	db 0			; segment base address, high
	
gdt_end:

gdt_ptr:
	dw gdt_end - gdt - 1		; size of GDT
	dd gdt						; gdt base address
	
