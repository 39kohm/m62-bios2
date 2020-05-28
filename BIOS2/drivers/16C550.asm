;*************************************
; M62 BIOS
;*************************************
; 16C550uart.asm - 16C550 UART Driver
;************************************
; Much taken from Matt Cook's code
; Changed to take the UART base address from "conaddr"

;***************************************************************************
;UART_INIT
;Function: Initialize the UART to BAUD Rate 9600 (4 MHz clock input)
;***************************************************************************
_UART_INIT:
			LD		HL, conaddr
			LD		C, (HL)
			INC		C
			INC		C
			INC		C
            LD		A,$80				;Mask to Set DLAB Flag
			OUT		(C),A
			LD     	A,26 
			LD		C, (HL)
			OUT    	(C),A			;Set BAUD rate to 9600
			LD     	A,00
			INC		C
			OUT    	(C),A			;Set BAUD rate to 9600
			LD     	A,$03
			INC		C
			INC		C
			OUT    	(C),A			;Set 8-bit data, 1 stop bit, reset DLAB Flag
			LD	   	A,$01
			LD		C, (HL)
			INC		C
			OUT    	(C),A			;Enable receive data available interrupt only
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
			PUSH	HL
UART_TX_RDY_LP:	
			LD		HL, conaddr
			LD		C, (HL)
			INC		C
			INC		C
			INC		C
			INC		C
			INC		C
			IN		A,(C)			;Fetch the control register
			BIT 	5,A					;Bit will be set if UART is ready to send
			JP		Z,UART_TX_RDY_LP		
			POP		HL
			POP     AF
			RET
	
;***************************************************************************
;UART_TX
;Function: Transmit character in A to UART
;***************************************************************************
_UART_TX:
			PUSH	HL
			CALL  _UART_TX_RDY	;;;;; UART_TX_RDY			;Make sure UART is ready to receive
			LD		HL, conaddr
			LD		C, (HL)
			OUT   (C),A				;Transmit character in A to UART
			POP		HL
			RET
				
;***************************************************************************
;UART_RX_READY
;Function: Check if UART is ready to receive
;***************************************************************************
_UART_RX_RDY:
			PUSH 	AF	
			PUSH	HL				
UART_RX_RDY_LP:			
			LD		HL, conaddr
			LD		C, (HL)
			INC		C
			INC		C
			INC		C
			INC		C
			INC		C
			IN		A,(C)			;Fetch the control register
			BIT 	0,A					;Bit will be set if UART is ready to receive
			JP		Z,UART_RX_RDY_LP		
			POP		HL
			POP     AF
			RET
	
;***************************************************************************
;UART_RX
;Function: Receive character in UART to A
;***************************************************************************
_UART_RX:
			PUSH	HL				
			CALL  _UART_RX_RDY			;;;;;;;  UART_RX_RDY			;Make sure UART is ready to receive
			LD		HL, conaddr
			LD		C, (HL)
			IN    A,(C)				;Receive character in UART to A
			POP		HL
			RET			
