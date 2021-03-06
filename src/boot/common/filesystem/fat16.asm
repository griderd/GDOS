; fat16.asm
; Implements the File Allocation Table, 16-bit, for floppy disks

; Real Mode address calculation: segment * 16 + offset

; The boot sector is loaded at 0000:7C00 = 0x0000 * 16 + 0x7C00 = 0x7C00
;=========================================================================
[BITS 16]
[ORG 0x7C00]

; jump over the table
jmp main
;nop	; do nothing

OEM_ID 				db 'GDOS    '	; OEM Identifier
BytesPerSector		dw 512			; Bytes per sector. 1.44 MB disks have 1440 KB bytes, one sector, and one cluster
SectorsPerCluster	db 1			; One sector per cluster. The whole disk is one sector.
ReservedSectors		dw 3			; The number of reserved sectors. Includes the boot record.
									; I'm using two additional sectors for a second-stage bootloader.
NumberOfFATs		db 2			; The number of FATs.
NumberOfRootEntries dw 512			; The number of possible root entries.
TotalSectors		dw 2880			; Total number of sectors
MediaDescriptor		db 0xF0			; 3.5 inch, 2-sided, 18 sector, 1.44 MB disk
SectorsPerFat		dw 9			; Number of sectors that occupy the FAT
SectorsPerTrack		dw 18			; Number of sectors per track
HeadsPerCylinder	dw 2			; Number of heads per cylinder
HiddenSectors		dd 0
TotalSectorsBig		dd 0
DriveNumber			db 0
Reserved			db 0
ExtBootSignature	db 0x29			; Indicates the following three bytes fields are available
VolumeSerialNumber	dd 0xA0A1A2A3	; Random 32-bit number to help track removable media and determine if the correct one is inserted.
VolumeLabel			db '           '; 11-character field
FileSystemType		db 'FAT16   '

%define ReservedRegion 		0
%define ReservedRegion_Size	3

%define FATRegion 			4
%define FATRegion_Size		18

%define RootDirRegion		22
%define RootDirRegion_Size	32

%define DataRegion 			54
%define DataRegion_Size		2829