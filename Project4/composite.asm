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
; (insert additional procedures here)
END main

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
		call edx
		call ReadInt
		call CrLf
		;Store eax for after the call
		push eax

		;Push eax as an argument
		push eax
		call validate
		
		cmp eax, 0
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
;1 if valid, 0 if not, in eax
validate PROC
	push ebp
	mov ebp, esp
	mov eax, [ebp + 8]
	cmp eax, LOW_BOUND
	jl invalid
	cmp eax, HIGH_BOUND
	jg invalid
	
	mov eax, 1

	pop ebp
	ret 4 
	invalid:
		mov ebx, 0
		pop ebp
		ret 4
validate ENDP

showComposites PROC
	ret
showComposites ENDP

isComposite PROC
	ret
isComposite ENDP

farewell PROC
	ret
farewell ENDP