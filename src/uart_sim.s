@-------------------------------------------------------------------
@ File:           uart_sim.s
@ Author:         Francisco Ítalo & Pedro Botelho
@ Date:           03/04/2021
@ Institution:    Federal University of Ceará
@ Institution ID: 472012 & 471047
@
@ Description:    Simulates the UART protocol, decoding UART pulses
@                 or ASCII characters.
@
@ Implementation: Developed in ARM 32-bit Assembly.
@ License:        GNU General Public License v3.0
@ Compiling:      make it         
@ Running:        make run        
@ Debugging:      make debug        
@-------------------------------------------------------------------


.TEXT

.ARM

.INCLUDE "copycat.lib"
.INCLUDE "uart_sim.lib"


@-------------------------------------------------------------------
_abortProgram:
@ Description: Restore stack pointer to default position and exit.
@ Receives:    Nothing.
@ Returns:     Nothing.
@-------------------------------------------------------------------
	@RESTORE STACK POINTER
	MOV sp, r10

	@EXIT SYSCALL
	MOV r7, #EXIT_FUNCTION
	MOV r0, #EXIT_STATUS
	SWI #0

@-------------------------------------------------------------------
_decodeUART:
@ Description: Decode UART pulses of a file into ASCII characters.
@ Receives:    Input string, with the UART pulses, in r1, output
@              string, where the ASCII characters will be placed, in
@              r2.
@ Returns:     The decoded character in the required string.
@-------------------------------------------------------------------
	PUSH {LR}

	POP  {PC}


@-------------------------------------------------------------------
_decodeCHAR:
@ Description: p
@ Receives:    p
@ Returns:     p
@-------------------------------------------------------------------
	PUSH {LR}

	POP {PC}
	

@-------------------------------------------------------------------
_optionError:
@ Description: Prints an error message and exits.
@ Receives:    Nothing.
@ Returns:     Nothing.
@-------------------------------------------------------------------
	LDR r1, =optionErrorString
	BL _printString
	B _end


.DATA

.BALIGN 4

@System Strings
optionErrorString: .ASCIZ "\nUARTsim: Invalid option.\nAborting.\n"
