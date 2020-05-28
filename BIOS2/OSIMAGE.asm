;*********************************************
; M62 - BIOS 2 OS image (this runs from RAM)
;*********************************************
; OSIMAGE.asm
;*********************************************
; By Peter Murray
; https://www.m62.ca
;*********************************************
; Compile with TASM using -80 -x -g3 -c -f00
;*********************************************

MLOCATION:		.EQU	$4000
conaddr:		.EQU	$7700	; Where the console UART I/O base port address resides
cfaddr:			.EQU	$7701	; Where the CF I/O base port address resides

.ORG MLOCATION  ; Run this at MLOCATION
ENTRY:			jp	OSIMAGE

BIOS_VERSION:	.BYTE	"\r\nM62 BIOS v2.0.0\r\n", EOS
BUILD_DATE:		.BYTE	"March 2nd 2020\r\n", EOS

OSIMAGE:		
					LD		SP,$7FFF		; Load the stack pointer for stack operations.
					LD		HL, BIOS_VERSION
					CALL	PUTS
					LD		HL, BUILD_DATE
					CALL	PUTS
					LD		HL, conaddr
					LD		(HL), $08		; Default console port
					LD		HL, cfaddr
					LD		(HL), $30		; Default CF port
					CALL	START_CLI
					HALT



#INCLUDE	"jmptbl.asm"				; Jump table

#INCLUDE	"drivers/16C550.asm"		; 16C550 UART driver
#INCLUDE	"core/console.asm"			; console routines
#INCLUDE	"core/delays.asm"			; delay routines
#INCLUDE	"core/math.asm"				; math routines
#INCLUDE	"core/strings.asm"			; strings routines
#INCLUDE	"core/cli.asm"				; command line interface

.END
