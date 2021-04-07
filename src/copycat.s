@-------------------------------------------------------------------
@ File:           copycat.s
@ Author:         Francisco Ítalo & Pedro Botelho
@ Date:           03/04/2021
@ Institution:    Federal University of Ceará
@ Institution ID: 472012 & 471047
@
@ Description:    Copies data from one file to another. The input file
@                 must exist. The output file can be inexistent.
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


@-------------------------------------------------------------------
_abortProgram:
@ Description: Restore stack pointer to default position and exit
@              with error code.
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
_getInput:
@ Description: Get user input from keyboard.
@ Receives:    Memory address where the string must be placed in r4.
@ Returns:     The string in the desired address.
@-------------------------------------------------------------------
	PUSH {LR}
	MOV r7, #READ_FUNCTION
	MOV r0, #STD_IN
	LDR r1, =tempBuffer 
	MOV r2, #OPERATE_ONE_BYTE
	__inner_getInput:
		SWI #0
		LDRB r3, [r1]
		CMP r3, #LINE_FEED
		POPeq {PC}
		CMP r3, #SPACE
		POPeq {PC}
		STRB r3, [r4], #1
		B __inner_getInput


@-------------------------------------------------------------------
_openFile:
@ Description: Open the desired file.
@ Receives:    The file path/name in r0, flags in r1, and permissions
@              in r2. Also the address where the FD will me saved in
@              r5. Some explanations:
@	           -> Flags: states how the file will be handled. For an
@                        example: 0x40 create the file if it doesn't
@                        exist, and 0x1 define the write-only access
@                        mode. Hence, 0x40|0x1=0x41 represent both.  
@	           -> Permissions: formally called 'mode' states who can 
@                              access and what can be done with it.
@                              For example, 0x1FF gives all user 
@                              read, write and execution permissions.
@ Returns:     The file descriptor, FD, in r0. In case of some error
@              r0 will receive a number bellow or equal to zero, show
@              an error message and exit.
@-------------------------------------------------------------------
	PUSH {LR}
	MOV r7, #OPEN_FUNCTION
	SWI #0
	CMP r0, #OPEN_ERROR
	STR r0, [r5]
	POP {PC}


@-------------------------------------------------------------------
_closeFile:
@ Description: Closes the required file.
@ Receives:    The file descriptor in r0.
@ Returns:     Nothing.
@-------------------------------------------------------------------
	PUSH {LR}
	MOV r7, #CLOSE_FUNCTION
	SWI #0
	POP {PC}


@-------------------------------------------------------------------
_copyFile:
@ Description: Copies data from an input file to an output file.
@ Receives:    The input FD in r8 and the output FD in r9.
@ Returns:     Nothing (Aside for the data into an output file).
@-------------------------------------------------------------------
	PUSH {LR}
	LDR r1, =tempBuffer
	MOV r2, #OPERATE_ONE_BYTE
	_readFile:
		MOV r0, r8
		MOV r7, #READ_FUNCTION
		SWI #0
		CMP r0, #END_OF_FILE
		POPle {PC}
	_writeFile:
		MOV r0, r9
		MOV r7, #WRITE_FUNCTION
		SWI #0	
		B _readFile


@-------------------------------------------------------------------
_fileToString:
@ Description: Copies data from a file to memory.
@ Receives:    The string address, where the data will be placed, in 
@              r1, and the input file descriptor, in r8.
@ Returns:     The data in the requested string, in memory.
@-------------------------------------------------------------------
	PUSH {LR}
	MOV r2, #OPERATE_ONE_BYTE
	MOV r7, #READ_FUNCTION
	__inner_fileToString:
		MOV r0, r8
		SWI #0
		CMP r0, #END_OF_FILE
		POPle {PC}
		ADD r1, r1, #1 
		B __inner_fileToString


@-------------------------------------------------------------------
_stringToFile:
@ Description: Copies data from memory to file.
@ Receives:    The string address, where the data is, in r1, and the 
@              output file descriptor, in r9.
@ Returns:     Nothing (Aside for the data in the requested file).
@-------------------------------------------------------------------
	PUSH {LR}
	MOV r2, #OPERATE_ONE_BYTE
	MOV r7, #WRITE_FUNCTION
	__inner_stringToFile:
		MOV r0, r9
		SWI #0
		LDR r3, [r1], #1
		CMP r3, #END_OF_FILE
		POPle {PC}
		B __inner_stringToFile


@-------------------------------------------------------------------
_printString:
@ Description: Print a message in the terminal.
@ Receives:    The string address in r1.
@ Returns:     Nothing.
@-------------------------------------------------------------------
	PUSH {LR}
	MOV R7, #WRITE_FUNCTION
	MOV R0, #STD_OUT
	MOV R2, #OPERATE_ONE_BYTE
	__inner_printString:
		SWI #0	
		LDRB r3, [r1, #1]!
		CMP r3, #END_OF_STRING
		Bne __inner_printString	
	POP {PC}


@-------------------------------------------------------------------
_clearString:
@ Description: Clear a string in the memory, filling it with zeros.
@ Receives:    The string address in r4.
@ Returns:     The string in r4 empty.
@-------------------------------------------------------------------
	PUSH {LR}
	PUSH {r4}
	MOV r1, #0
	__inner_clearString:
		LDRB r0, [r4]
		CMP r0, #0
		POPeq {r4}
		POPeq {PC}
		STRB r1, [r4], #1
		B __inner_clearString


.DATA

.BALIGN 4

@System Variables
tempBuffer:        .BYTE 1
