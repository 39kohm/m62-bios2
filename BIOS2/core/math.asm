;************************************************************************************
; math.asm
;************************************************************************************
; Set of Math routines
;	These have been borrowed from resources on the internet,
;	I have put a link of their sources and attributed to the name I could find.
;************************************************************************************
; I intend to write my own versions of these routines at a later date
;************************************************************************************

;************************************************************************************
;Multiply 8-bit values
;************************************************************************************
;In:  Multiply H with E
;Out: HL = result
;************************************************************************************
; by Grauw
; based on code at http://map.grauw.nl/articles/mult_div_shifts.php
;************************************************************************************
_MULT_8:	LD		D, $00
			LD		L, D
			LD		B, $08
_MULT_8_LOOP:
			ADD		HL, HL
			JR		NC, _MULT_8_NOADD
			ADD		HL, DE
_MULT_8_NOADD:
			DJNZ	_MULT_8_LOOP
			RET

;************************************************************************************
;Multiply 8-bit value with a 16-bit value
;************************************************************************************
;In: Multiply A with DE
;Out: HL = result
;************************************************************************************
; by Grauw
; based on code at http://map.grauw.nl/articles/mult_div_shifts.php
;************************************************************************************
_MULT_12:	LD		L, $00
			LD		B, $08
_MULT_12_LOOP:
			ADD		HL, HL
			ADD		A, A
			JR		NC, _MULT_12_NOADD
			ADD		HL, DE
_MULT_12_NOADD:
			DJNZ	_MULT_12_LOOP
			RET

;************************************************************************************
;Multiply 16-bit values (with 16-bit result)
;************************************************************************************
;In: Multiply BC with DE
;Out: HL = result
;************************************************************************************
; by Grauw
; based on code at http://map.grauw.nl/articles/mult_div_shifts.php
;************************************************************************************
_MULT_16:	LD		A, B
			LD		B, $10
_MULT_16_LOOP:
			ADD		HL, HL
			SLA		C
			RLA
			JR		NC, _MULT_16_NOADD
			ADD		HL, DE
_MULT_16_NOADD:
			DJNZ	_MULT_16_LOOP
			RET

;************************************************************************************
;Multiply 16-bit values (with 32-bit result)
;************************************************************************************
;In: Multiply BC with DE
;Out: BCHL = result
;************************************************************************************
; by Grauw
; based on code at http://map.grauw.nl/articles/mult_div_shifts.php
;************************************************************************************
_MULT_32:	LD		A, C
			LD		C, B
			LD		HL, $00
			LD		B, $10
_MULT_32_LOOP:
			ADD		HL, HL
			RLA
			RL		C
			JR		NC, _MULT_32_NOADD
			ADD		HL, DE
			ADC		A, $00
			JP		NC, _MULT_32_NOADD
			INC		C
_MULT_32_NOADD:
			DJNZ	_MULT_32_LOOP
			LD		B, C
			LD		C, A
			RET


;************************************************************************************
;Divide 8-bit values
;************************************************************************************
;In: Divide E by divider C
;Out: A = result, B = rest
;************************************************************************************
; by Grauw
; based on code at http://map.grauw.nl/articles/mult_div_shifts.php
;************************************************************************************
_DIV_8:		XOR		A
			LD		B, $08
_DIV_8_LOOP:
			RL		E
			RLA
			SUB		C
			JR		NC, _DIV_8_NOADD
			ADD		A, C
_DIV_8_NOADD:
			DJNZ	_DIV_8_LOOP
			LD		B, A
			LD		A, E
			RLA
			CPL
			RET

;************************************************************************************
;Divide 16-bit values (with 16-bit result)
;************************************************************************************
;In: Divide BC by divider DE
;Out: BC = result, HL = rest
;************************************************************************************
; by Grauw
; based on code at http://map.grauw.nl/articles/mult_div_shifts.php
;************************************************************************************
_DIV_16:	LD		HL, $00
			LD		A, B
			LD		B, $08
_DIV_16_LOOP1:
			RLA
			ADC		HL, HL
			SBC		HL, DE
			JR		NC, _DIV_16_NOADD1
			ADD		HL, DE
_DIV_16_NOADD1:
			DJNZ	_DIV_16_LOOP1
			RLA
			CPL
			LD		B, A
			LD		A, C
			LD		C, B
			LD		B, $08
_DIV_16_LOOP2:
			RLA
			ADC		HL, HL
			SBC		HL, DE
			JR		NC, _DIV_16_NOADD2
			ADD		HL, DE
_DIV_16_NOADD2:
			DJNZ	_DIV_16_LOOP2
			RLA
			CPL
			LD		B, C
			LD		C, A
			RET
	
	
;************************************************************************************
;Square root of 16-bit value
;************************************************************************************
;In:  HL = value
;Out:  D = result (rounded down)
;************************************************************************************
; written by Ricardo Bittencourt
; http://www.cpcwiki.eu/index.php/Programming:Square_Root
; and https://www.msx.org/news/websites/en/msx-assembly-page-update-0
;************************************************************************************
_SQRT_16:	LD		DE, $0040
			LD		A, L
			LD		L, H
			LD		H, D
			OR		A
			LD		B, 8
_SQRT_16_LOOP:
			SBC		HL, DE
			JR		NC, _SQRT_16_SKIP
			ADD		HL, DE
_SQRT_16_SKIP:
			CCF
			RL		D
			ADD		A, A
			ADC		HL, HL
			ADD		A, A
			ADC		HL, HL
			DJNZ	_SQRT_16_LOOP
			RET
	