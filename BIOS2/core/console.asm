;*************************************
; M62 BIOS 2
;*************************************
; console.asm - BIOS 2 Console Routines
;************************************

; Console values
EOS:				.EQU	$00							; Null Character (End Of String)
CR:					.EQU	$0D							; Carriage Return
LF:					.EQU	$0A							; Line Feed

CLS_STRING:			.BYTE	ESC,"[f",ESC,"[2J",EOS		; Printing this screen to the terminal will clear the screen and return the cursor to the top left of the screen.
CLEAR_STRING:		.BYTE	ESC,"[f]"
HOME_STRING:		.BYTE	ESC,"[2J"
BS:					.EQU	$08							; Backspace character
ESC:				.EQU	$1B							; Escape character

;***************************************************************************
;GET_CHAR
;Function: Get ASCII character from user into Accumulator
;***************************************************************************			
_GETC:
			CALL	_UART_RX				;Get char into Acc
			RET
			
;***************************************************************************
;GET_HEX_NIBBLE
;Function: Translates char to HEX nibble in bottom 4 bits of A
;***************************************************************************
_GET_HEX_NIB:      
			CALL	_GETC
			CALL	_TO_UPPER			;Character has to be upper case
            CALL    _CHAR_ISHEX      	;Is it a hex digit?
            JP      NC,_GET_HEX_NIB  	;Yes - Jump / No - Continue
			CALL    _PUTC
			CP      '9' + 1         	;Is it a digit less or equal '9' + 1?
            JP      C,_GET_HEX_NIB_1 	;Yes - Jump / No - Continue
            SUB     $07             	;Adjust for A-F digits
_GET_HEX_NIB_1:                
			SUB     '0'             	;Subtract to get nib between 0->15
            AND     $0F             	;Only return lower 4 bits
            RET	
				
;***************************************************************************
;GET_HEX_BTYE
;Function: Gets HEX byte into A
;***************************************************************************
_GET_HEX_BYTE:
            CALL    _GET_HEX_NIB			;Get high nibble
            RLC     A					;Rotate nibble into high nibble
            RLC     A
            RLC     A
            RLC     A
            LD      B,A					;Save upper four bits
            CALL    _GET_HEX_NIB			;Get lower nibble
            OR      B					;Combine both nibbles
            RET				
			
;***************************************************************************
;GET_HEX_WORD
;Function: Gets two HEX bytes into HL
;***************************************************************************
_GET_HEX_WORD:
			PUSH    AF
            CALL    _GET_HEX_BYTE		;Get high byte
            LD		H,A
            CALL    _GET_HEX_BYTE    	;Get low byte
            LD      L,A
            POP     AF
            RET
;***************************************************************************
;PRINT_STRING
;Function: Prints string to terminal program
;***************************************************************************
_PUTS:
			JP		UART_PRNT_STR
;			CALL    UART_PRNT_STR
;			RET
			
;***************************************************************************
;PRINT_CHAR
;Function: Get upper case ASCII character from Accumulator to UART
;***************************************************************************			
_PUTC:
			CALL	UART_TX				;Echo character to terminal
			RET			
			
;***************************************************************************
;PRINT_NEW_LINE
;Function: Prints carriage return and line feed
;***************************************************************************			

NEW_LINE_STRING: 	.BYTE "\r\n",EOS

_PRINT_NEW_LINE:
			PUSH	HL
			LD 		HL,NEW_LINE_STRING			
			CALL    PUTS			
			POP		HL
			RET
			
;***************************************************************************
;PRINT_HEX_NIB
;Function: Prints a low nibble in hex notation from Acc to the serial line.
;***************************************************************************
_PRINT_HEX_NIB:
			PUSH 	AF
            AND     $0F             	;Only low nibble in byte
            ADD     A,'0'             	;Adjust for char offset
            CP      '9' + 1         	;Is the hex digit > 9?
            JP      C,_PRINT_HEX_NIB_1	;Yes - Jump / No - Continue
            ADD     A,'A' - '0' - $0A 	;Adjust for A-F
_PRINT_HEX_NIB_1:
			CALL	_PUTC        	;Print the nibble
			POP		AF
			RET
				
;***************************************************************************
;PRINT_HEX_BYTE
;Function: Prints a byte in hex notation from Acc to the serial line.
;***************************************************************************		
_PRINT_HEX_BYTE:
			PUSH	AF					;Save registers
            PUSH    BC
            LD		B,A					;Save for low nibble
            RRCA						;Rotate high nibble into low nibble
			RRCA
			RRCA
			RRCA
            CALL    _PRINT_HEX_NIB		;Print high nibble
            LD		A,B					;Restore for low nibble
            CALL    _PRINT_HEX_NIB		;Print low nibble
            POP     BC					;Restore registers
            POP		AF
			RET
			
;***************************************************************************
;PRINT_HEX_WORD
;Function: Prints the four hex digits of a word to the serial line from HL
;***************************************************************************
_PRINT_HEX_WORD:     
			PUSH 	HL
            PUSH	AF
            LD		A,H
			CALL	_PRINT_HEX_BYTE		;Print high byte
            LD		A,L
            CALL    _PRINT_HEX_BYTE		;Print low byte
            POP		AF
			POP		HL
            RET			
;*****************************************************************************
; STRCMP	- STRing CoMPare - compares 2 strings
;*****************************************************************************
; Entry:
;		HL and DE	= Address of strings to compare
;		A			= Number of chars to compare
; Return:
;		A			= FF if strings match, any other value means they didn't
;*****************************************************************************
; By Peter Murray
; https://www.m62.ca
;*****************************************************************************
;_STRCMP:
;			PUSH	BC
;			LD		B, $00
;			LD		C, A
;_SC_LOOP:	LD		A, (DE)
;			CPI
;			JP		NZ, _SC_DONE
;			LD		A, C
;			CP		$FF
;			INC		DE
;			JP		NZ, _SC_LOOP
;_SC_DONE:	LD		A, C
;			POP		BC
;			RET

;***************************************************************************
;TO_UPPER
;Function: Convert character in Accumulator to upper case
;***************************************************************************
; By Matt Cook
; https://z80project.wordpress.com/author/matthewcook6254/
;***************************************************************************		
_TO_UPPER:       
			CP      'a'             	; Nothing to do if not lower case
            RET     C
            CP      'z' + 1         	; > 'z'?
            RET     NC              	; Nothing to do, either
            AND     $5F             	; Convert to upper case
            RET		
			

;***************************************************************************
;CHAR_ISHEX
;Function: Checks if value in A is a hexadecimal digit, C flag set if true
;***************************************************************************		
; By Matt Cook
; https://z80project.wordpress.com/author/matthewcook6254/
;***************************************************************************		
_CHAR_ISHEX:         
										;Checks if Acc between '0' and 'F'
			CP      'F' + 1       		;(Acc) > 'F'? 
            RET     NC              	;Yes - Return / No - Continue
            CP      '0'             	;(Acc) < '0'?
            JP      NC,_CHAR_ISHEX_1 	;Yes - Jump / No - Continue
            CCF                     	;Complement carry (clear it)
            RET
_CHAR_ISHEX_1:       
										;Checks if Acc below '9' and above 'A'
			CP      '9' + 1         	;(Acc) < '9' + 1?
            RET     C               	;Yes - Return / No - Continue (meaning Acc between '0' and '9')
            CP      'A'             	;(Acc) > 'A'?
            JP      NC,_CHAR_ISHEX_2 	;Yes - Jump / No - Continue
            CCF                     	;Complement carry (clear it)
            RET
_CHAR_ISHEX_2:        
										;Only gets here if Acc between 'A' and 'F'
			SCF                     	;Set carry flag to indicate the char is a hex digit
            RET
			
_CLRSCR:
			LD		HL, CLEAR_STRING
			CALL	_PUTS
			LD		HL, HOME_STRING
			CALL	_PUTS
			RET
			