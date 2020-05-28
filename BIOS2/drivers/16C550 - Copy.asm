;*************************************
; M62 BIOS
;*************************************
; 16C550uart.asm - 16C550 UART Driver
;************************************
; Much taken from Matt Cook's code

UART_BASE:			.EQU	$08			; Base address for the UART

;***************************************************************************
;UART_INIT
;Function: Initialize the UART to BAUD Rate 9600 (4 MHz clock input)
;***************************************************************************
_UART_INIT:
            LD     A,$80				;Mask to Set DLAB Flag
			OUT    (UART_BASE+3),A
			LD     A,26 
			OUT    (UART_BASE),A			;Set BAUD rate to 9600
			LD     A,00
			OUT    (UART_BASE+1),A			;Set BAUD rate to 9600
			LD     A,$03
			OUT    (UART_BASE+3),A			;Set 8-bit data, 1 stop bit, reset DLAB Flag
			LD	   A,$01
			OUT    (UART_BASE+1),A			;Enable receive data available interrupt only
			RET		
		
;***************************************************************************
;UART_PRNT_STR:
;Function: Print out string starting at MEM location (HL) to 16550 UART
;***************************************************************************
_UART_PRNT_STR:
			PUSH	AF
			PUSH	HL
UART_PRNT_STR_LP:
			LD		A,(HL)
            CP		EOS					;Test for end byte
            JP		Z,UART_END_PRNT_STR	;Jump if end byte is found
			CALL	_UART_TX		;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; UART_TX
            INC		HL					;Increment pointer to next char
            JP		UART_PRNT_STR_LP	;Transmit loop
UART_END_PRNT_STR:
			POP		HL
			POP		AF
			RET	 
			 	
;***************************************************************************
;UART_TX_READY
;Function: Check if UART is ready to transmit
;***************************************************************************
_UART_TX_RDY:
			PUSH 	AF
UART_TX_RDY_LP:			
			IN		A,(UART_BASE+5)			;Fetch the control register
			BIT 	5,A					;Bit will be set if UART is ready to send
			JP		Z,UART_TX_RDY_LP		
			POP     AF
			RET
	
;***************************************************************************
;UART_TX
;Function: Transmit character in A to UART
;***************************************************************************
_UART_TX:
			CALL  _UART_TX_RDY	;;;;; UART_TX_RDY			;Make sure UART is ready to receive
			OUT   (UART_BASE),A				;Transmit character in A to UART
			RET
				
;***************************************************************************
;UART_RX_READY
;Function: Check if UART is ready to receive
;***************************************************************************
_UART_RX_RDY:
			PUSH 	AF					
UART_RX_RDY_LP:			
			IN		A,(UART_BASE+5)			;Fetch the control register
			BIT 	0,A					;Bit will be set if UART is ready to receive
			JP		Z,UART_RX_RDY_LP		
			POP     AF
			RET
	
;***************************************************************************
;UART_RX
;Function: Receive character in UART to A
;***************************************************************************
_UART_RX:
			CALL  _UART_RX_RDY			;;;;;;;  UART_RX_RDY			;Make sure UART is ready to receive
			IN    A,(UART_BASE)				;Receive character in UART to A
			RET			
