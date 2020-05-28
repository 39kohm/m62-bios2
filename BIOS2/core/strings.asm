;**********************************************
; M62 BIOS
;**********************************************
; strings.asm - String routines for the M62-OS
;**********************************************
; All routines in this library were written
; by Peter Murray
; https://www.m62.ca
;**********************************************

;*****************************************************************************
; STRCMP	- STRing CoMPare - compares 2 strings
;*****************************************************************************
; String compare
; Entry: 	
;			HL, DE	: Location of strings to compare
; Exit: 	
;			Z flag set for match, clear for not match
;*****************************************************************************
_STRCMP:	PUSH	HL
_STRCMPL:	LD		A, (DE)
			CP		(HL)
			JP		NZ, _STRCMPDN
			CP		$00
			JP		Z, _STRCMPDN
			INC		DE
			INC		HL
			JP		_STRCMPL
_STRCMPDN:	POP		HL
			RET

_STRCMPX:	LD		A, (DE)
			CP		(HL)
			RET		NZ
			CP		$00
			RET		Z
			INC		DE
			INC		HL
			JP		_STRCMP

;*****************************************************************************
; STRISNUM	- Checks if a string is a valid decimal value
;*****************************************************************************
; Is String a decimal number
; Entry: 	
;			HL : Location of string to test
; Exit: 	
;			Z flag set if valid decimal value
;*****************************************************************************
_STRISNUM:	PUSH	HL
			CALL	_STRLEN
			POP		HL
			LD		A, B
			CP		$00
			JP		Z, infalse
i_n_loop:	LD		A, (HL)			; Get the next character
			CP		$00				; Is it null?
			RET		Z
			CP		'0' ; $30
			JP		C, infalse		; if less than '0' then it's not  number
			CP		'9'+1 ; $39
			JP		C, indonext		; if less/equal to '9' then it is a number
infalse:	LD		A, $01			; clear Z and return
			CP		$00
			RET
indonext:	INC		HL
			JP		i_n_loop

;*****************************************************************************
; STRISHEX	- Checks if a string is a valid hex value
;*****************************************************************************
; Is String a hex number
; Entry: 	
;			HL : Location of string to test
; Exit: 	
;			Z flag set if valid hex value
;*****************************************************************************
_STRISHEX:	PUSH	HL
			CALL	_STRLEN
			POP		HL
			LD		A, B
			CP		$00
			JP		Z, ihfalse
i_h_loop:	LD		A, (HL)			; Get the next character
			CP		$00				; Is it null?
			RET		Z
			CP		'0' ; $30
			JP		C, ihfalse		; if less than '0' then it's not a hex number
			CP		'9'+1 ; $39
			JP		C, ihdonext		; if less/equal to '9' then it is a number so we can loop again
			; Add checking of a-f,A-F
			CP		'A'	; $41
			JP		C, ihfalse		; if less than 'A' then it's not a hex number
			CP		'F'+1 ; $46
			JP		C, ihdonext		; if less/equal to 'F' then it is a number so we can loop again
			CP		'a' ; $61
			JP		C, ihfalse		; if less than 'a' then it's not a hex number
			CP		'f'+1 ; $66
			JP		C, ihdonext		; if less/equal to 'f' then it is a number so we can loop again
ihfalse:	LD		A, $01			; clear Z and return
			CP		$00
			RET
ihdonext:	INC		HL
			JP		i_h_loop

;*****************************************************************************
; STRLEN	- Counts the length of a string
;*****************************************************************************
; String Length
; Entry: 	
;			HL : Location of string to count
; Exit: 	
;			B : length of the string (null terminator is not counted)
;*****************************************************************************
_STRLEN:	LD		B, $00
sl_next:	LD		A, (HL)
			CP		$00
			RET		Z
			INC		B
			INC		HL
			JP		sl_next			
			
			

;**********************************************************************************
; STRSUBCNT	- Counts the number of substrings seperated with specificed seperator
;**********************************************************************************
; Entry: 	
;			HL : Location of string to count
;			C  : Seperator character to use
; Exit: 	
;			B  : Stores the number of parameter substrings (command not counted)
;*****************************************************************************
_STRSUBCNT:
			LD		B, $00				; set substring counter to 0
cs_readnext:
			LD		A, $00
			CP		(HL)				; Compare the character with null (are we at the end of the string)
			RET		Z					; If it's null, we are done
			LD		A, C				; Seperator character
			CP		(HL)				; Compare the character with the seperator
			JP		NZ, cs_nextchar		; if there isn't a separator we don't increment the counter
			INC		B					; Increment substring count
cs_nextchar:
			INC		HL
			JP		cs_readnext
			

;**********************************************************************************
; STRHEXVAL	- Gets the value of a hex number string (16-Bit max)
;**********************************************************************************
; Entry: 	
;			HL : Location of string to convert (doesn't check validity)
; Exit: 	
;			BC : Value of the string (B=MSB,C=LSB) (if <256, B will be 0)
;*****************************************************************************
_STRHEXVAL:	LD		BC, $0000
_SHV_LOOP:	LD		A, (HL)		; Grab the char
			CP		$00
			RET		Z			; if null char, we are done
			PUSH	HL			; Store the char location
			CALL	_CHARTOVAL
			LD		E, A		; Store the val of char in E for now
			; shift B left by 4 and clear lower nibble | A<-B, RLA*4, clear low nibble, B<-A
			LD		A, B
			RLA
			RLA
			RLA
			RLA
			LD		B, $F0
			AND		B
			LD		B, A
			; copy C to A, right shift by 4 bits and clear top nibble
			LD		A, C
			RRA
			RRA
			RRA
			RRA
			LD		D, $0F
			AND		D
			ADD		A, B
			LD		B, A
			; shift C left by 4 and clear lower nibble
			LD		A, C
			RLA
			RLA
			RLA
			RLA
			LD		C, $F0
			AND		C
			LD		C, A
			; Add value of character to C
			LD		A, E	; Get the val of char back
			ADD		A, C
			LD		C, A
			POP		HL			; Recall char location
			INC		HL			; Next char location
			JP		_SHV_LOOP


;**********************************************************************************
; CHARTOVAL	- Gets the value of a character
;**********************************************************************************
; Entry:
;			A : Char to convert to value
; Exit: 	
;			A : Value of that character
;*****************************************************************************
_CHARTOVAL:	PUSH	BC
			CP		'9'+1				; Is the char <= '9'?
			JP		C, _CHV_NUM
			CP		'G'					; is the char <= 'F'?
			JP		C, _CHV_UPC
			LD		B, 'a'-$0A
			SUB		B					; Subtract offset from the char to convert to value
			POP		BC
			RET
_CHV_NUM:	LD		B, '0'
			SUB		B					; Subtract offset from the char to convert to value
			POP		BC
			RET
_CHV_UPC:	LD		B, 'A'-$0A
			SUB		B					; Subtract offset from the char to convert to value
			POP		BC
			RET

; UNIMPLEMENTED ROUTINES, DUMMY ROUTINES TO SATISFY JUMP TABLE


;**********************************************************************************
; STRDECVAL	- Gets the value of a decimal number string (16-Bit max)
;**********************************************************************************
; Entry: 	
;			HL : Location of string to count
; Exit: 	
;			BC : Value of the string (B=MSB,C=LSB) (if <256, B will be 0)
;*****************************************************************************
_STRDECVAL:	LD		BC, $0000
			RET

