TITLE Average (average.asm)
; Program Description:
; Author:
; Creation Date:
; Revisions:
; Date:
LOWER_BOUND = -100
INCLUDE Irvine32.inc
.data
	extraCreditMessage BYTE "**EC: I number the lines. I do a floating point average",0
	greetingMessage BYTE "I'm Tristan and this is Average! What is your name?",0
	userName BYTE 128 DUP(0)
	userGreetingMessage BYTE "Hello, ",0
	promptMessage BYTE " Give me a number between -100 and -1. Non-negative number to start averaging: ",0
	byeMessage BYTE "Bye, ",0
	zeroMessage BYTE "You didn't give me any numbers :(",0
	inputsMessage BYTE "Inputs: ",0
	sumMessage BYTE "The sum: ",0
	roundedAverageMessage BYTE "The rounded average: ",0
	floatAverageMessage BYTE "Floating point average: ",0 
	errorMessage BYTE "No, idiot!",0


	exponent DWORD ?
	significand DWORD ?

	accumulator SDWORD 0
	inputs SDWORD 0
.code
main PROC
	;Extra credit boi
	mov edx, OFFSET extraCreditMessage
	call WriteString
	call CrLf

	;Give title and say hi to user
	mov edx, OFFSET greetingMessage
	call WriteString
	call CrLf
	
	mov edx, OFFSET userName
	mov ecx, SIZEOF userName
	call ReadString

	;Hello, user
	mov edx, OFFSET userGreetingMessage
	call WriteString

	mov edx, OFFSET userName
	call WriteString


	;Start getting numbers
	inputLoop:
		call CrLf
		
		;Extra credit and prompt
		mov eax, inputs
		call WriteDec
		mov edx, OFFSET promptMessage
		call WriteString

		call ReadInt
		
		;Values greater than 0 stop the input loop
		cmp eax, 0
		jge done
		
		;Values lower than LOWER_BOUND are rebuked
		cmp eax, LOWER_BOUND
		jge success

		;Give an error message if value is less than LOWER_Bound
		mov edx, OFFSET errorMessage
		call WriteString

		jmp inputLoop
		
		success:
		inc inputs
		add accumulator, eax

		jmp inputLoop
	done:
	
	cmp inputs, 0

	;Skip processing if no inputs given
	je specialMessage
		
	;Write number of inputs
	mov edx, OFFSET inputsMessage
	call WriteString
	mov eax, inputs
	call WriteDec
	call CrLf
	
	;Write sum of inputs
	mov edx, OFFSET sumMessage
	call WriteString
	mov eax, accumulator
	call WriteInt
	call CrLf
	
	;Calculate integer average
	mov eax, accumulator
	cdq
	idiv inputs

	;Write integer average
	mov edx, OFFSET roundedAverageMessage
	call WriteString
	call WriteInt
	call CrLf


	;Extra credit: Calculate floating point average
	fild accumulator
	fidiv inputs

	;Write floating point average
	mov edx, OFFSET floatAverageMessage
	call WriteString
	call WriteFloat
	call CrLf

	jmp bye

	;If the user doesn't input any values
	specialMessage:
		mov edx, OFFSET zeroMessage
		call WriteString
		call CrLf

	bye:
		mov edx, OFFSET byeMessage
		call WriteString
		mov edx, OFFSET userName
		call WriteString
		call CrLf
	call ReadInt
exit
main ENDP


END main

