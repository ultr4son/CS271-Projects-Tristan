TITLE Composite Numbers (composite.asm)
; Program Description: Calculate composite numbers. (Not primes)
; Author: Tristan Thompson
; Creation Date: 2/14/17
; Revisions:
; Date: 2/14/17
INCLUDE Irvine32.inc
LOW_BOUND = 1
HIGH_BOUND = 400
ROW_BREAK = 10
.data
greetingMessage BYTE "My name is Tristan Thompson and this is Composite Numbers!",0
numberInputMessage BYTE "Give me a number between 1 and 400 composite numbers: ",0
errorMessage BYTE "No, idiot!",0
spaces BYTE "   ",0
byeMessage BYTE "Bye!",0

outputs DWORD 0
.code

main PROC
	call introduction

	call getUserData

	push eax
	call showComposites
	
	call farewell

exit
main ENDP
;Greet the user.
;Parameters: (none)
;Returns: (none)
introduction PROC
	mov edx, OFFSET greetingMessage
	call WriteString
	call CrLf
	ret
introduction ENDP

;Get the composite number from the user.
;Parameters: (none)
;Returns: The composite number in eax.
getUserData PROC
	mov eax, 0
	userDataInputLoop:
		mov edx, OFFSET numberInputMessage
		call WriteString
		call ReadInt
		call CrLf
		;Store eax for after the call
		push eax

		;Push eax as an argument
		push eax
		call validate
		
		cmp eax, 0

		;Restore eax to user input
		pop eax 
		
		je userDataInputError
		;Since we passed the checks and the value is in eax we can ret.
		ret
		userDataInputError:
			mov edx, OFFSET errorMessage
			call WriteString
			call CrLf
			jmp userDataInputLoop
getUserData ENDP

;Validate a given number
;Parameters: the number to validate 
;Returns: 1 if valid, 0 if not, in eax
validate PROC
	push ebp
	mov ebp, esp

	num EQU [ebp + 8]

	mov eax, num
	cmp eax, LOW_BOUND
	jl invalid
	cmp eax, HIGH_BOUND
	jg invalid
	
	mov eax, 1

	pop ebp
	ret 4 
	invalid:
		mov eax, 0
		pop ebp
		ret 4
validate ENDP

;Display composites
;Parameters: The number of composites to display
;Returns: (none)
showComposites PROC
	push ebp
	mov ebp, esp
	
	n EQU [ebp + 8]
	
	mov ebx, 3 ; First composite is 4
	mov ecx, n

	compositeLoop:
		inc ebx
		;preserve ebx
		push ebx
		;preserve ecx
		push ecx

		push ebx
		
		
		call isComposite
		pop ecx
		pop ebx

		cmp eax, 0
		jg printComposite
		jmp compositeLoop
		printComposite:
			mov eax, ebx
			call WriteDec
			mov edx, OFFSET spaces
			call WriteString
			inc outputs
			mov edx, outputs
			cmp edx, ROW_BREAK
			je break
			loop compositeLoop
			;no longer looping
			jmp done
			break:
				mov outputs, 0
				call CrLf
			loop compositeLoop
	done:
	pop ebp
	ret 4
showComposites ENDP

;Check if composite
;Parameters: A positive number to check
;Returns: 1 if composite, 0 if not
isComposite PROC
	push ebp
	mov ebp, esp

	num EQU [ebp + 8]


	mov eax, num

	;Positive numbers less than 4 are not composite
	cmp eax, 4 
	jl fail
	
	mov ebx, 2
	mov ecx, 0
	checkLoop:
		mov eax, num
		cdq
		;If we've reached the number and there were no clean divides, we don't need to check if it's composite anymore
		cmp eax, ebx
		je fail

		div ebx
		inc ebx

		;If there was a clean division with a non-one (ebx starts at 2) and non-num (checked above) we can call the number composite 
		cmp edx, 0
		je composite
		jmp checkLoop
	composite:
		pop ebp
		mov eax, 1
		ret 4
	fail:
		pop ebp
		mov eax, 0
		ret 4
	 
isComposite ENDP

;Prints a goodbye message
;Parameters: (none)
;Returns: (none)
farewell PROC
	mov edx, OFFSET byeMessage
	call WriteString
	call CrLf
	call ReadInt
	ret
farewell ENDP
END main

