@-------------------------------------------------------------------
@ File:           main.s
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

.GLOBAL main


main:
	@SET r10 AS STACK BASE
	MOV r10, sp

	@SHOW WELCOME MESSAGE
	LDR r1, =welcomeString
	BL _printString

	@GET INPUT FILE's NAME
	LDR r4, =inputFile
	BL _getInput

	@GET OUTPUT FILE's NAME
	LDR r4, =outputFile
	BL _getInput
	 
	@OPENING INPUT FILE
	LDR r0, =inputFile
	MOV r1, #DONT_CREATE
	MOV r2, #READ_ONLY
	LDR r5, =inputFD
	BL _openFile
	
	@SET r8 AS INPUT FD
	MOV r8, r0	
	
	@OPENING OUTPUT FILE
	LDR  r0, =outputFile
	LDR  r1, =CREATE_WRITE
	LDR  r2, =PERMISSIONS
	LDR  r5, =outputFD
	BL  _openFile

	@SET r9 AS OUTPUT FD
	MOV r9, r0
	
	@LOAD FILE DATA TO MEMORY
	LDR r1, =inputFileData
	BL _fileToString

	@UART->CHAR
	LDR r1, =inputFileData
	LDR r2, =outputFileData
	BL _decodeUART

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

welcomeString:  .ASCIZ "\n\033[1;37mUARTsim\033[0m: \033[1;33mInitialization\033[0m: Welcome to UART Simulator.\n\nType down the path of the input file, then the output file\n\n"
goodbyeString:  .ASCIZ "\n\033[1;37mUARTsim\033[0m: \033[1;33mShutdown\033[0m: All set. Exiting assistant.\n"

@User variables
inputFile:      .SKIP 100
inputFD:        .SKIP 4
outputFile:     .SKIP 100
outputFD:       .SKIP 4	
inputFileData:  .SKIP 1050621
outputFileData: .SKIP 1050621 
