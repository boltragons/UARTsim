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
@ Receives:    Input string, with the UART pulses, in r1, and output
@              string, where the ASCII characters will be placed, in
@              r2.
@ Returns:     The decoded character in the required string.
@-------------------------------------------------------------------
	PUSH {LR}
	MOV r6, #8
	_decodeUART_procedure:
		MOV r4, #0
		MOV r5, #10
		__inner_decodeUART_procedure:
			SUB r5, r5, #1
			LDRB r3, [r1], #1

			@IF r3 IS A END-OF-STRING AND r5 IS ZERO -> EXIT
			CMP r3, #0
			POPeq {PC}

			@IF r3 IS A LINE-FEED AND r5 IS ZERO -> LOOP
			CMP r3, #0xA
			Beq _decodeUART_procedure

			@INIT BIT
			CMP r5, #9
			MOVeq r0, #0x30
			BLeq  _verifyValue
			Beq   __inner_decodeUART_procedure

			@END BIT
			CMP r5, #0
			MOVeq r0, #0x31
			BLeq  _verifyValue
			STReqB r4, [r2], #1
			Beq   _decodeUART_procedure

			@BONDARIES BIT
			CMP r3, #0x2F
			Bls _UARTcodeError
			CMP r3, #0x31
			Bhi _UARTcodeError

			@LOGIC
			SUB r7, r6, r5 
			AND r3, r3, #1
			LSL r3, r3, r7
			ORR r4, r4, r3

			B __inner_decodeUART_procedure


@-------------------------------------------------------------------
_decodeCHAR:
@ Description: Decode ASCII characters of a file into UART pulses.
@ Receives:    Input string, with the UART pulses, in r1, and output 
@              string, where the ASCII characters will be placed, in 
@              r2.
@ Returns:     The decoded pulses in the required string.
@-------------------------------------------------------------------
	PUSH {LR}
	MOV r5, #0x30
	MOV r6, #0x31
	_decodeCHAR_procedure:
		MOV r7, #7
		LDRB r3, [r1], #1

		CMP r3, #0xA
		Beq _decodeCHAR_procedure

		@IF r3 IS A END-OF-STRING -> EXIT
		CMP r3, #0
		POPeq {PC}

		STRB r5, [r2], #1

		__inner_decodeCHAR_procedure:
			AND r4, r3, #1
			ADD r4, r4, #0x30
			STRB r4, [r2], #1

			CMP r7, #0
			STReqB r6, [r2], #1
			Beq _decodeCHAR_procedure

			LSR r3, r3, #1
			SUB r7, r7, #1
			B __inner_decodeCHAR_procedure

@-------------------------------------------------------------------
_verifyValue:
@ Description: Verify two value equality. If not equal, then a error
@              message is displayed and the program aborts. 
@ Receives:    The values in r0 and r3.
@ Returns:     If equal, zero flag is activated.
@-------------------------------------------------------------------
	PUSH  {LR}
	CMP r3, r0
	POPeq {PC}
	B _UARTcodeError


@-------------------------------------------------------------------
_getOption:
@ Description: Gets the user's desired option from the keyboard and
@              ensures that the option is valid.
@ Receives:    The address for the option to be stored in r4, and the
@              message address in r1.
@ Returns:     The option in the memory and in r11.
@-------------------------------------------------------------------
	PUSH {LR}
	MOV r8, r4
	MOV r9, r1
	__inner_getOption:
		BL _printString
		BL _getInput
		LDRB r11, [r4, #-1]!

		CMP r11, #0x30
		Bls __optionError_getOption
		CMP r11, #0x32
		POPls {PC} 

	__optionError_getOption:
		LDR  r1, =optionErrorString
		BL  _printString
		MOV  r4, r8
		MOV  r1, r9
		B   __inner_getOption


@-------------------------------------------------------------------
_UARTcodeError:
@ Description: Prints an error message and exits.
@ Receives:    Nothing.
@ Returns:     Nothing.
@-------------------------------------------------------------------
	LDR r1, =UARTcodeErrorString
	BL _printString
	B  _abortProgram


@-------------------------------------------------------------------
_CHARcodeError:
@ Description: Prints an error message and exits.
@ Receives:    Nothing.
@ Returns:     Nothing.
@-------------------------------------------------------------------
	LDR r1, =CHARcodeErrorString
	BL _printString
	B  _abortProgram



.DATA

.BALIGN 4

@System Strings
optionErrorString:   .ASCIZ "\n\033[1;37mUARTsim\033[0m: \033[1;31mInvalid option\033[0m: Try again.\n\n"
UARTcodeErrorString: .ASCIZ "\n\033[1;37mUARTsim\033[0m: \033[1;31mFatal error\033[0m: Invalid UART pulse.\nAborting.\n\n"
CHARcodeErrorString: .ASCIZ "\n\033[1;37mUARTsim\033[0m: \033[1;31mFatal error\033[0m: Invalid ASCII code.\nAborting.\n\n"

