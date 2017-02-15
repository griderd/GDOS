; fat16helper.asm
; Contains macros for getting fields from the FAT16 partition loaded at 0x7C00

%define Partition 0x7C00
%define OEM_ID Partition+3
%define BytesPerSector Partition+0xB
%define SectorsPerCluster Partition+0xD
%define ReservedSectors Partition+0xE
%define NumberOfFATs Partition+0x10
%define NumberOfRootEntries Partition+0x11
%define TotalSectors Partition+0x13
%define MediaDescriptor Partition+0x15
%define SectorsPerFat Partition+0x16
%define SectorsPerTrack Partition+0x18
%define HeadsPerCylinder Partition+0x1A
%define HiddenSectors Partition+0x1C
%define TotalSectorsBig Partition+0x20
%define DriveNumber Partition+0x24
%define Reserved Partition+0x25
%define ExtBootSignature Partition+0x26
%define VolumeNumber Partition+0x27
%define VolumeLabel Partition+0x2B
%define FileSystemType Partition+0x36

; Macros defining disk locations and sizes of FAT16 regions
%define ReservedRegion 		0
%define ReservedRegion_Size	3

%define FATRegion 			4
%define FATRegion_Size		18

%define RootDirRegion		22
%define RootDirRegion_Size	32

%define DataRegion 			54
%define DataRegion_Size		2829