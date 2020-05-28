;*****************************
; routine_entry.asm
;*****************************
; Created by Don Prefontaine
;*****************************
; Delay values
DELAY_FIFTY:		.EQU	0105h						; 50us
DELAY_HUNDRED:		.EQU	0110h						; 100us
DELAY_THOUSAND:		.EQU	01B6h						; 1000us
DELAY_HALF64K:		.EQU	7FFFh						; 179ms
DELAY_FULL64K:		.EQU	0FFFFh						; 360ms
DELAY_SCROLL:		.EQU	3FFFh						; 89ms. Used to slow-scroll an LCD display.
DELAY_DINCER:		.EQU	0220h						; 1.6ms. Used by Dincer Aydin for one of his LCD initialization routines.

;********************
; BIOS routine
;********************
_loopDELAY:  				
		NOP
		NOP
        DEC L
        JP NZ, loopDELAY
        DEC H
        JP NZ, loopDELAY
        RET            

;********************
; Coding example
;********************
;		LD	HL,	DELAY_DINCER
;		CALL	loopDELAY