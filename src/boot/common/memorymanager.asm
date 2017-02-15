; memorymanager.asm
; This is the boot-level memory manager.
; This file dictates the position and length of each area of memory.

; The first-stage bootstrap loads to 7C00.
%define Stage1Boot 		0x7C00
%define Stage1Boot_Len 	0x200

; We're loading the second-stage boot to 7E00, directly behind the first stage.
; It's precise length is unknown right now but we'll assume it's about 1 KB.
%define Stage2Boot		0x7E00
%define Stage2Boot_Len	0x400

%define Stack			0x9C00

%define RootDir			0x9D00
%define RootDirLen		0x4000
%define RootDirSectors	32

%define FileTable		0xDD00
%define FileTable_Len	0x1200

; The Kernel is definately going to be more than 1KB, but for the moment
; let's assume that it is exactly 1 KB in size.
%define Kernel			0xEF00
%define Kernel_Len		0x400