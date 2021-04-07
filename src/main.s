@-------------------------------------------------------------------
@ File:           main.s
@ Author:         Francisco Ítalo & Pedro Botelho
@ Date:           07/04/2021
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

.GLOBAL main


main:
	@SET r10 AS STACK BASE
	MOV r10, SP

	@SHOW WELCOME MESSAGE
	LDR r1, =welcomeString
	BL _printString

	@GET OPERATION OPTION
	LDR r1, =optionString
	LDR r4, =operationOption
	BL _getOption

	@SHOW INPUT FILE MESSAGE
	LDR r1, =inputFileString
	BL _printString

	@GET INPUT FILE's NAME
	LDR r4, =inputFile
	MOV r6, r4
	_getInputFile:
		BL _getInput

		@OPENING INPUT FILE
		LDR r0, =inputFile
		MOV r1, #DONT_CREATE
		MOV r2, #READ_ONLY
		LDR r5, =inputFD
		BL _openFile
		
		@SET r8 AS INPUT FD
		MOV r8, r0	

		@CHECKS IF THE FILE EXISTS 
		CMP r8, #OPEN_ERROR
		LDRle r1, =inputFileErrorString
		BLle _printString

		@IF NOT, TRY AGAIN
		MOVeq r4, r6
		BLeq _clearString
		Beq _getInputFile


	@SHOW OUTPUT FILE MESSAGE
	LDR r1, =outputFileString
	BL _printString

	@GET OUTPUT FILE's NAME
	LDR r4, =outputFile
	MOV r6, r4
	_getOutputFile:
		BL _getInput

		@OPENING OUTPUT FILE
		LDR  r0, =outputFile
		LDR  r1, =CREATE_WRITE
		LDR  r2, =PERMISSIONS
		LDR  r5, =outputFD
		BL  _openFile

		@SET r9 AS OUTPUT FD
		MOV r9, r0

		@CHECKS IF THE FILE NAME IS VALID 
		CMP r9, #OPEN_ERROR
		LDRle r1, =outputFileErrorString
		BLle _printString

		@IF NOT, TRY AGAIN
		MOVeq r4, r6
		BLeq _clearString
		Beq _getOutputFile


	@LOAD FILE DATA TO MEMORY
	LDR r1, =inputFileData
	BL _fileToString

	@CHOOSE OPERATION BASED ON USER'S CHOICE
	LDR r1, =inputFileData
	LDR r2, =outputFileData
	CMP r11, #0x31
	BLeq _decodeUART
	BLne _decodeCHAR

	@LOAD MEMORY DATA TO FILE
	LDR r1, =outputFileData
	BL _stringToFile

	@SHOW GOODBYE MESSAGE
	LDR r1, =goodbyeString
	BL _printString

	@CLOSING FILES
	MOV r0, r8
	BL _closeFile
	MOV r0, r9
	BL _closeFile
	
	@RESTORE STACK POINTER
	MOV sp, r10

	@EXIT SYSCALL
	MOV r7, #EXIT_FUNCTION
	MOV r0, #EXIT_STATUS
	SWI #0
	

.BALIGN 4
.DATA

welcomeString:         .ASCIZ "\n\033[1;37mUARTsim\033[0m: \033[1;33mInitialization\033[0m: Welcome to UART Simulator v0.0.3\n\n                         Under GNU General Public License v3.0\n\n"
optionString:          .ASCIZ "\n\033[1;37mUARTsim\033[0m: \033[1;33mOperation\033[0m: Select the desired operation:\n\n(1) \033[1;94mDecode UART pulses into ASCII characters\033[0m\n(2) \033[1;94mDecode ASCII characters into UART pulses\033[0m\n\n"
inputFileString:       .ASCIZ "\n\033[1;37mUARTsim\033[0m: \033[1;33mInput File\033[0m: Insert input file's name, then press enter.\n"
outputFileString:      .ASCIZ "\n\033[1;37mUARTsim\033[0m: \033[1;33mOutput File\033[0m: Insert output file's name, then press enter.\n"
goodbyeString:         .ASCIZ "\n\033[1;37mUARTsim\033[0m: \033[1;33mShutdown\033[0m: All set. Exiting assistant.\n"

inputFileErrorString:  .ASCIZ "\n\033[1;37mUARTsim\033[0m: \033[1;31mInvalid Input File\033[0m: Specified input file doesn't exist. Try again.\n"
outputFileErrorString: .ASCIZ "\n\033[1;37mUARTsim\033[0m: \033[1;31mInvalid Output File\033[0m: Invalid file name. Try again.\n"

@User variables
operationOption: .BYTE 1
inputFile:       .SKIP 100
inputFD:         .SKIP 4
outputFile:      .SKIP 100
outputFD:        .SKIP 4	
inputFileData:   .SKIP 1050621
outputFileData:  .SKIP 1050621 
