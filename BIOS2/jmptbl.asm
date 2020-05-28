;*************************************
; M62 BIOS 2
;*************************************
; jmptbl.asm - BIOS 2 Jump Table
;************************************
.ORG $6000

; Standard I/O Routines
PUTC:					JP _PUTC					; Write Character from A to standard output
PUTS:					JP _PUTS					; Write ASCIIZ String pointed to by HL to standard output
GETC:					JP _GETC					; Read Character from standard input into A
TO_UPPER:				JP _TO_UPPER				; Make the lower case character in A upper case
PRINT_NEW_LINE:			JP _PRINT_NEW_LINE			; Send new line characters (CR+LF) to standard output
CHAR_ISHEX:				JP _CHAR_ISHEX				; C Flag is set if the character in A is hex
GET_HEX_NIB:			JP _GET_HEX_NIB				; Get single hex digit, store in lower nibble of A from standard input
GET_HEX_BYTE			JP _GET_HEX_BYTE			; Get hex byte, stores in A from standard input
GET_HEX_WORD:			JP _GET_HEX_WORD			; Get hex word, stores in HL from standard input
PRINT_HEX_NIB:			JP _PRINT_HEX_NIB			; Send hex character of lower nibble of A to standard output
PRINT_HEX_BYTE:			JP _PRINT_HEX_BYTE			; Send hex character pairs of value in A to standard output
PRINT_HEX_WORD:			JP _PRINT_HEX_WORD			; Send 4 character hex word in HL to standard output

; UART Routines
UART_INIT:				JP _UART_INIT
UART_PRNT_STR:			JP _UART_PRNT_STR
UART_TX_RDY:			JP _UART_TX_RDY
UART_TX:				JP _UART_TX
UART_RX_RDY:			JP _UART_RX_RDY
UART_RX:				JP _UART_RX

; Delay Routine
loopDELAY:  			JP _loopDELAY
STRCMP:					JP _STRCMP					; Compares 2 strings (In: HL, DE address of strings, A = # of chars, Out: A = FF if match)

; Math Routines
MULT_8:					JP _MULT_8					; Multiply 8-bit values (In:  Multiply H with E, Out: HL = result)
MULT_12:				JP _MULT_12					; Multiply 8-bit value with a 16-bit value (In: Multiply A with DE, Out: HL = result)
MULT_16:				JP _MULT_16					; Multiply 16-bit values (with 16-bit result) (In: Multiply BC with DE, Out: HL = result)
MULT_32:				JP _MULT_32					; Multiply 16-bit values (with 32-bit result) (In: Multiply BC with DE, Out: BCHL = result)
DIV_8:					JP _DIV_8					; Divide 8-bit values (In: Divide E by divider C, Out: A = result, B = rest)
DIV_16:					JP _DIV_16					; Divide 16-bit values (with 16-bit result) (In: Divide BC by divider DE, Out: BC = result, HL = rest)
SQRT_16:				JP _SQRT_16					; Square root of 16-bit value (In:  HL = value, Out:  D = result (rounded down))
