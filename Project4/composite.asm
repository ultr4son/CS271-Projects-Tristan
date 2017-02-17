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
numberInputMessage BYTE "Give me a number between 1 and 400: ",0
errorMessage BYTE "No, idiot!",0
spaces BYTE "   ",0
byeMessage BYTE "Bye!"
.code

main PROC
	call introduction

	call getUserData

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
	
	mov ebx, 4 ; First composite is 4
	mov ecx, n

	compositeLoop:
		push ebx
		call isComposite
		cmp eax, 0
		jg printComposite
		loop compositeLoop
		printComposite:
			call WriteDec
			loop compositeLoop
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
	cmp eax, 4 ;Positive numbers less than 4 are not composite
	jl done
	
	mov ebx, 2

	done:
		pop ebp 
		ret 
isComposite ENDP

;Prints a goodbye message
;Parameters: (none)
;Returns: (none)
farewell PROC
	ret
farewell ENDP
END main

