;************************************
; M62 BIOS2
;************************************
; M62BIOS2.asm - Main BIOS 2 file
;************************************
; By Peter Murray & Don Prefontaine
;************************************
#DEFINE 		STACK_ADDRESS 	$7FFF

;********************
; System entry point
;********************

.ORG $0000	; Reset vector
RST_VECTOR:		JP START	; Jump to start of code

.ORG $0038	; INT vector
INT_VECTOR:		JP START	; For now we just go back to start

.ORG $0066	; NMI Vector
#IFDEF NMI_HANDLER
				JP NMI_START
#ENDIF

NMI_VECTOR:		JP START	; For now we just go back to start

START:
				DI							; Disable interrupts
				LD		SP,STACK_ADDRESS	; Load the stack pointer for stack operations.

				HALT

.END