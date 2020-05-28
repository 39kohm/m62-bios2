;*************************************
; M62 BIOS 2
;************************************
; cli.asm - Command Line Interface
;************************************
; (C)Copyright 2019
; By Peter Murray
;************************************

CMD_BUFF:			.EQU	$7D00					; Command buffer location
CMD_SIZE:			.EQU	30							; command buffer size
PARSE_CNT:			.EQU	CMD_BUFF+CMD_SIZE					; Parse count (# parameters)
PARSE_TBL:			.EQU	PARSE_CNT+1					; Parse Pointer Table
CLI_VERSION:			.BYTE	"\r\nCLI Version 1.0\r\n",EOS

START_CLI:		
			JP		CMD_LINE
			
CMD_LINE:
			LD		HL, PROMPT
			CALL	_PUTS
			LD		HL, CMD_BUFF		; HL points to command buffer
			LD		C, 0				; size of current command set to 0
CMD_NEXT:	CALL	_GETC				; Wait for and get character into A
			LD		(HL), A				; push the character into the buffer
			CP		CR					; Check for Carriage Return					
			JP		Z,CMD_DONE
			CP		LF					; Check for Line Feed					
			JP		Z,CMD_DONE
			CP		BS					; Check for Back Space				
			JP		Z,CMD_BS
			CP		ESC					; Check for Escape character
			JP		Z,CMD_LINE			; Jump back to command line
			CALL	_PUTC
			LD		A, C
			CP		CMD_SIZE
			JP		Z, CMD_NEXT			; if we take up all the buffer then end the line
			INC		HL
			INC		C			
			JP		CMD_NEXT
CMD_DONE:	;INC		HL
			LD		(HL), EOS			; put the EOS character at the end of the buffer
			JP		CHECK_CMD
CMD_BS:		LD		A, C
			CP		$00
			JP		Z, CMD_NEXT			; if buffer is empty, go back
			LD		(HL), EOS
			DEC		HL
			DEC		C			
			LD		A, BS
			CALL	_PUTC
			LD		A, ' '
			CALL	_PUTC
			LD		A, BS
			CALL	_PUTC
			JP		CMD_NEXT

CHECK_CMD:	;PUSH	HL
			CALL	PRINT_NEW_LINE			
			LD		HL, CMD_BUFF
			CALL	parse_cmdbuff		; Parse the buffer read for checking

;;;;; Uncomment to show what was parsed out of the command line
;			LD		A, B
;			CALL	PRINT_NEW_LINE			
;			CALL	PRINT_HEX_BYTE
;			CALL	PRINT_NEW_LINE			
;			LD		HL, CMD_BUFF
;			CALL	PUTS
;			LD		A, '|'
;			CALL	PUTC
;			CALL	PRINT_NEW_LINE			
			
			; Check for HELP Command
			LD		HL, CMD_BUFF
			LD		DE, HELP_CMD
			CALL	_STRCMP
			JP		Z, HELP_COMMAND
			; Check for ? Command
			LD		HL, CMD_BUFF
			LD		DE, HELP2_CMD
			CALL	_STRCMP
			JP		Z, HELP_COMMAND

			; Check for CLS Command
			LD		HL, CMD_BUFF
			LD		DE, CLS_CMD
			CALL	_STRCMP
			JP		Z, CLEAR_SCR			
			; Check for RESTART Command
			LD		HL, CMD_BUFF
			LD		DE, RST_CMD
			CALL	_STRCMP
			JP		Z, RST_COMMAND
			; Check for R. Command (restart shorthand)
			LD		HL, CMD_BUFF
			LD		DE, RST2_CMD
			CALL	_STRCMP
			JP		Z, RST_COMMAND
			; Check for Memstat Command
;			LD		HL, CMD_BUFF
;			LD		DE, MST_CMD
;			CALL	_STRCMP
;			JP		Z, MEMSTAT
			; Check for Application Command
;			LD		HL, CMD_BUFF
;			LD		DE, APP_CMD
;			CALL	_STRCMP
;			JP		Z, APP_COMMAND

			; Check for Version Command
			LD		HL, CMD_BUFF
			LD		DE, VER_CMD
			CALL	_STRCMP
			JP		Z, VER_COMMAND

;;;;;;;; Test commands ;;;;;;;;;;;;;;;;;;;;;;;;;;;;
			; Check for TEST Command
;			LD		HL, CMD_BUFF
;			LD		DE, TEST_CMD
;			CALL	_STRCMP
;			JP		Z, CLI_TEST			
			; Check for TEST2 Command
;			LD		HL, CMD_BUFF
;			LD		DE, TEST2_CMD
;			CALL	_STRCMP
;			JP		Z, CLI_TEST2


			; Get here when no matching command
			;	eventually we will insert code to check if it's an executable filename in the current device first
			LD		HL, NO_CMD
			CALL	_PUTS
			JP		CMD_LINE
LOOP:		HALT
			JP		LOOP

VER_COMMAND:
			LD		HL, BIOS_VERSION
			CALL	PUTS
			LD		HL, BUILD_DATE
			CALL	PUTS
			LD		HL, CLI_VERSION
			CALL	_PUTS
			JP		CMD_LINE

CLEAR_SCR:	PUSH	AF
			CALL	_CLRSCR				
			POP		AF
			LD		A, $00
			JP		CMD_LINE			; return to command line

RST_COMMAND:
			LD		HL, PARSE_CNT
			LD		A, $00
			CP		(HL)
			JP		Z, RST_NOPARAM		; If no parameters specified then show help for restart command
			LD		DE, PARSE_TBL		
			LD		A, (DE)
			LD		L, A
			INC		DE
			LD		A, (DE)				; point HL to first parameter
			LD		H, A
			LD		DE, WARM_PARAM		; Check for warm parameter
			CALL	_STRCMP
			JP		Z, OSIMAGE			; Restart OS
			LD		DE, PARSE_TBL		
			LD		A, (DE)
			LD		L, A
			INC		DE
			LD		A, (DE)				; point HL to first parameter
			LD		H, A
			LD		DE, COLD_PARAM		; Check for cold parameter
			CALL	_STRCMP
			JP		Z, RST_COLD			; Do cold restart
			LD		HL, RST_IVLD
			CALL	PUTS				; Write "Invalid Parameter!" message
RST_NOPARAM:							; we get here too if a non-valid parameter exists
			LD		HL, RST_HELP
			CALL	PUTS
			JP		CMD_LINE
RST_COLD:	LD		A, $00
			LD		C, $00
			OUT		(C), A				; Switch Bank 0 back to ROM
			JP		$0000
		
			
RST_IVLD:	.BYTE	"\r\Invalid parameter!",EOS
RST_HELP:	.BYTE	"\r\n",ESC,"[7m restart usage: ",ESC,"[0m\r\n"
			.BYTE	"  restart cold = restart back into BIOS\r\n"
			.BYTE	"  restart warm = restart back into OS\r\n",EOS

PROMPT:		.BYTE	"\r\n>",EOS



; PARSE_CNT = Count of parameter strings
; PARSE_TBL = Location of beginging of Parse Table (SSx)
; | # substrings | SS1 PTR | SS2 PTR | ... | SSn PTR |
			
; parse the of substrings in a string
;	This will change the space characters to EOS chars ($00/Null) and put the address of
;	the start of each parameter substring on the table starting at PARSE_TLB
;	the beginning of the command string will still be at CMD_BUFF
; Exit:		B		: Stores the number of parameter substrings (command not counted)
parse_cmdbuff:
			LD		B, $00				; set substring counter to 0
			LD		DE, PARSE_TBL		; Set DE to be the location of the parse table
			LD		HL, CMD_BUFF
ps_readnext:
			LD		A, $00
			CP		(HL)				; Compare the character with null (are we at the end of the string)
			JP		Z, ps_done			; If it's null, we are done, update count at PARSE_CNT
			LD		A, ' '				; Seperator character, space in this case
			CP		(HL)				; Compare the character with the seperator
			JP		NZ, ps_nextchar		; if there isn't a separator we don't increment the counter
			LD		(HL), $00			; Change seperator to EOS char (splits the string)
			INC		B					; Increment substring count
			INC		HL					; Next char location
			LD		A, L
			LD		(DE), A				; Put the low byte of the substring address on the table
			INC		DE
			LD		A, H
			LD		(DE), A				; Put the high byte of the substring address on the table
			INC		DE
			JP		ps_readnext			; Go around again
ps_nextchar:
			INC		HL
			JP		ps_readnext
ps_done:	LD		HL, PARSE_CNT
			LD		(HL), B				; Save the Parameter (substring) count to PARSE_CNT
			RET							; Return to CLI


; Command strings
CLS_CMD:		.BYTE	"cls",EOS
HELP_CMD:		.BYTE	"help",EOS
RST_CMD:		.BYTE	"restart",EOS
VER_CMD:		.BYTE	"ver",EOS

; Shorthand commands
HELP2_CMD:		.BYTE	"?",EOS
RST2_CMD:		.BYTE	"r.",EOS

TEST_CMD:		.BYTE	"test",EOS
TEST2_CMD:		.BYTE	"test2",EOS
; Parameter strings
WARM_PARAM:		.BYTE	"warm",EOS
COLD_PARAM:		.BYTE	"cold",EOS

NO_CMD:			.BYTE	"\r\nUnknown command, type help for help\r\n",EOS

HELP_COMMAND:
			LD		HL, PARSE_CNT
			LD		A, $00
			CP		(HL)
			JP		Z, SHOW_HELP		; If no parameters specified then show help for restart command
			LD		DE, PARSE_TBL		
			LD		A, (DE)
			LD		L, A
			INC		DE
			LD		A, (DE)				; point HL to first parameter
			LD		H, A
;			LD		DE, AST_PARAM			; Check for status parameter
;			CALL	_STRCMP
;			JP		Z, APP_STAT  		; Show application status			

			LD		DE, RST_CMD			; Asking for help on "restart"
			CALL	_STRCMP
			JP		Z, RST_NOPARAM

;			LD		DE, APP_CMD			; Asking for help on "app"
;			CALL	_STRCMP
;			JP		Z, APP_NOPARAM

			; no valid parameter was found:
			LD		HL, HLP_NOHELP
			CALL	PUTS
			JP		CMD_LINE

SHOW_HELP:	PUSH	AF
			LD		HL, HELP_STRING
			CALL	_PUTS
			POP		AF
			JP		CMD_LINE			; return to command line

HLP_NOHELP:	.BYTE	"\r\nNo help on that command was found.\r\n",EOS

HELP_STRING:.BYTE	"\r\n",ESC,"[7m Help ",ESC,"[0m\r\n"
			.BYTE	"restart (or r.) - Restarts the system\r\n"
			.BYTE	"cls             - Clear the screen\r\n"
			.BYTE	"help (or ?)     - This help menu\r\n",EOS

;#INCLUDE		"commands/help.asm"
;#INCLUDE		"commands/memstat.asm"
;#INCLUDE		"commands/application.asm"
;#INCLUDE		"commands/testcmd.asm"
;#INCLUDE		"core/bin_rx.asm"