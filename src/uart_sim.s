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
		_decodeUART_procedure_inner:
			SUB r5, r5, #1
			LDRB r3, [r1], #1

			CMP r3, #0
			bne vrf2
			CMP r5, #0
			bne vrf2
			POPeq {PC}

			vrf2:
			CMP r3, #0xA
            Bne vrf3
            CMP r5, #0
			Beq _decodeUART_procedure
            Bne _decodeUART_procedure_inner

            vrf3:
			CMP r5, #9
			MOVeq r0, #0x30
			BLeq  _verifyValue
			Beq   _decodeUART_procedure_inner

			CMP r5, #0
			MOVeq r0, #0x31
			BLeq  _verifyValue
			STReqB r4, [r2], #1
			Beq   _decodeUART_procedure

			CMP r3, #0x2F
			Bls _UARTcodeError
			CMP r3, #0x31
			Bhi _UARTcodeError

			SUB r7, r6, r5 
			AND r3, r3, #1
			LSL r3, r3, r7
			ORR r4, r4, r3

			B _decodeUART_procedure_inner


@-------------------------------------------------------------------
_decodeCHAR:
@ Description: Decode ASCII characters of a file into UART pulses.
@ Receives:    Input string, with the ASCII characters, in r1, and
@              output string, where the UART pulses will be placed,
@              in r2.
@ Returns:     The decoded pulses in the required string.
@-------------------------------------------------------------------
	PUSH {LR}
	ADD r2, r2, #9
	MOV r5, #8
	MOV r4, #1
	STRB r4, [r2], #-1
	MOV r4, #1
	_decodeCHAR_procedure:
		CMP r5, #0
		Beq end
		LDRB r3, [r1], #1
		STRB r3, [r2], #-1
		B _decodeCHAR_procedure
	end:
		STRB r4, [r2], #0
		POP {PC}
	
	

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
@ Description: Get user's option from keyboard.
@ Receives:    The string for the option to be stored in r4.
@ Returns:     The option in the memory and in r11.
@-------------------------------------------------------------------
	PUSH {LR}
	MOV r8, r4
	MOV r9, r1
	_getOption_inner:
		BL _printString
		BL _getInput
		LDRB r11, [r4, #-1]!

		CMP r11, #0x30
		Bls _getOption_optionError
		CMP r11, #0x32
		POPls {PC} 

	_getOption_optionError:
		LDR  r1, =optionErrorString
		BL  _printString
		MOV  r4, r8
		MOV  r1, r9
		B   _getOption_inner

@-------------------------------------------------------------------
_UARTcodeError:
@ Description: Prints an error message and exits.
@ Receives:    Nothing.
@ Returns:     Nothing.
@-------------------------------------------------------------------
	LDR r1, =UARTcodeErrorString
	BL _printString
	B  _abortProgram



.DATA

.BALIGN 4

@System Strings
optionErrorString:   .ASCIZ "\n\033[1;37mUARTsim\033[0m: \033[1;31mInvalid option\033[0m: Try again.\n\n"
UARTcodeErrorString: .ASCIZ "\n\033[1;37mUARTsim\033[0m: \033[1;31mFatal error\033[0m: Invalid UART pulse.\nAborting.\n\n"
