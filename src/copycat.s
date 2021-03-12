@-------------------------------------------------------------------
@ File:           copycat.s
@ Author:         Pedro Botelho
@ Date:           04/06/2021
@ Institution:    Federal University of Ceará
@ Institution ID: 471047
@
@ Description:    Copies data from one file to another. The input file
@                 must exist. The output file can be inexistent.
@ Implementation: Developed in ARM 32-bit Assembly.
@ Compiling:      gcc -g -O0 -Wall copycat.s -o copycat
@ License:        GNU General Public License v3.0
@-------------------------------------------------------------------

.GLOBAL main
.FUNC main
.ARM

main:
	@SET r10 AS STACK BASE
	MOV r10, sp

	@SHOW WELCOME MESSAGE
	LDR r1, =write_pleadString
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
	
	BL _copyFile

	@SHOW GOODBYE MESSAGE
	LDR r1, =goodbyeString
	BL _printString

	@CLOSING GILES
	MOV r0, r8
	BL _closeFile
	MOV r0, r9
	BL _closeFile

@-------------------------------------------------------------------
_end:
@ Description: Restore stack pointer to default position and exit.
@ Receives:    Nothing.
@ Returns:     Nothing.
@-------------------------------------------------------------------
	@RESTORE STACK POINTER
	MOV sp, r10

	@EXIT SYSCALL
	MOV r7, #EXIT_FUNCTION
	SWI #0

@-------------------------------------------------------------------
_getInput:
@ Description: Get user input from keyboard.
@ Receives:    Memory address where the string must be placed.
@ Returns:     The string in the desired address.
@-------------------------------------------------------------------
	PUSH {LR}
	MOV r7, #READ_FUNCTION
	MOV r0, #STD_IN
	MOV r2, #OPERATE_ONE_BYTE
	LDR r1, =tempBuffer 
	__inner_getInput:
		SWI #0
		LDRB r3, [r1]
		CMP r3, #LINE_FEED
		POPeq {PC}
		CMP r3, #SPACE
		POPeq {PC}
		STRB r3, [r4]
		ADD r4, r4, #1 
		B __inner_getInput

@-------------------------------------------------------------------
_openFile:
@ Description: Open the desired file.
@ Receives:    The file path/name in r0, flags in r1, and permissions
@              in r2. Also the address where the FD will me saved in
@              r5. Some explanations:
@	       -> Flags: states how the file will be handled. For an
@                        example: 0x40 create the file if it doesn't
@                        exist, and 0x1 define the write-only access
@                        mode. Hence, 0x40|0x1=0x41 represent both.  
@	       -> Permissions: formally called 'mode' states who can 
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
	CMP r0, #ERROR
	Ble _fileError
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
@ Returns:     Nothing.
@-------------------------------------------------------------------
	PUSH {LR}
	MOV r2, #1
	_readFile:
		MOV r0, r8
		LDR r1, =tempBuffer
		MOV r7, #READ_FUNCTION
		SWI #0
		CMP r0, #END_OF_FILE
		POPle {PC}
	_writeFile:
		MOV r0, r9
		LDR r1, =tempBuffer
		MOV r7, #WRITE_FUNCTION
		SWI #0	
		B _readFile

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
		ADD r1, r1, #1
		LDRB r3, [r1]
		CMP r3, #END_OF_STRING
		Bne __inner_printString	
	POP {PC}		

@-------------------------------------------------------------------
_fileError:
@ Description: Prints an error message and exits.
@ Receives:    Nothing.
@ Returns:     Nothing.
@-------------------------------------------------------------------
	LDR r1, =fileErrorString
	BL _printString
	B _end

.DATA
.BALIGN 4

@System Strings
write_pleadString: .ASCIZ "WELCOME TO COPYCAT ASSISTANT\n\nType down the path of the input file, then the output file.\n"
fileErrorString:   .ASCIZ "\nSpecified input file doesn't exist.\nAborting.\n"
goodbyeString:     .ASCIZ "\nAll set. Exiting assistant.\n"

@User variables
inputFile:  .SKIP 100
inputFD:    .SKIP 4
outputFile: .SKIP 100
outputFD:   .SKIP 4
tempBuffer: .SKIP 1

@Constants
.EQU EXIT_FUNCTION,    0x0001
.EQU READ_FUNCTION,    0x0003
.EQU WRITE_FUNCTION,   0x0004
.EQU OPEN_FUNCTION,    0x0005
.EQU CLOSE_FUNCTION,   0x0006

.EQU READ_ONLY,        0x0000
.EQU DONT_CREATE,      0x0000 
.EQU CREATE_WRITE,     0x0241
.EQU PERMISSIONS,      0x01FF

.EQU STD_OUT,          0x0001
.EQU STD_IN,           0x0001
.EQU OPERATE_ONE_BYTE, 0x0001

.EQU ERROR,            0x0000
.EQU END_OF_FILE,      0x0000
.EQU END_OF_STRING,    0x0000

.EQU LINE_FEED,        0x000A
.EQU SPACE,            0x0020
