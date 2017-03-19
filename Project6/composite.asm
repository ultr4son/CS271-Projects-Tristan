TITLE Composite (composite.asm)
; Program Description: Test the user on combinations
; Author: Tristan Thompson
; Creation Date: 3/18/17
; Revisions:
; Date: 3/18/17

MAX_N = 12
MIN_N = 3
RANGE_N = MAX_N - MIN_N

m_putStr MACRO address
	mov edx, address
	call WriteString
ENDM

m_putStrLn MACRO address
	mov edx, address
	call WriteString
	call CrLf
ENDM

m_randomRange MACRO min, max
	mov eax, max
	call RandomRange
	add eax, min
ENDM

INCLUDE Irvine32.inc
.data
	invalidNumError BYTE "This isn't a number: ",0
	introMessage BYTE "My name is Tristan and this is Composite Test!",0
	problemMessageHead BYTE "What is ",0
	problemMessageMid BYTE "C",0
	problemMessageEnd BYTE "?",0
	
	answerMessage BYTE "You wrote: ",0
	resultMessage BYTE "The answer was: ",0

	incorrectMessage BYTE "Wrong, idiot!",0
	correctMessage BYTE "You're right!",0

	continueMessage BYTE "Do another? (y to continue, other to quit): ",0
	continueAnswer BYTE 10 DUP(?)

	num DWORD ?
	combinationResult DWORD ?


	n DWORD ?
	r DWORD ?

.code
main PROC

	call introduction

main_loop:

	push OFFSET r
	push OFFSET n
	call showProblem

	push OFFSET num
	call getData

	push num
	push r
	push n
	push OFFSET combinationResult
	call showResult
	
	m_putStr OFFSET continueMessage

	mov edx, OFFSET continueAnswer
	mov ecx, SIZEOF continueAnswer
	call ReadString
	
	;If the answer has a lengh greater than 1 then it is invalid.
	mov ecx, 1
	cmp eax, ecx
	jg main_done
	
	;Check if user gave a y, do another problem if so.
	mov edx, OFFSET continueAnswer
	mov al, 'y'
	mov dl, BYTE PTR [edx]
	cmp dl, al
	je main_loop

main_done:
	exit

main ENDP

introduction PROC
	;TODO: turn this into a macro
	m_putStrLn OFFSET introMessage
	ret
introduction ENDP

;Generate random n and r and display the problem.
;Parameters:
;r: address of r
;n: address of n
showProblem PROC
	push ebp
	mov ebp, esp
	
	;Save used registers
	push eax
	push ebx
	push edx

	showProblem_n EQU [ebp + TYPE DWORD + TYPE DWORD]
	showProblem_r EQU [ebp + TYPE DWORD + TYPE DWORD * 2]

	call Randomize
	
	;Calculate n
	m_randomRange MIN_N, RANGE_N
 	
	mov ebx, [showProblem_n]
	mov [ebx], eax

	;Calculate r
	m_randomRange 1, eax


	mov ebx, showProblem_r
	mov [ebx], eax

	;Display problem
	m_putStr OFFSET problemMessageHead

	mov eax, showProblem_n
	mov eax, [eax]
	call WriteDec

	m_putStr OFFSET problemMessageMid

	mov eax, showProblem_r
	mov eax, [eax]
	call WriteDec

	m_putStrLn OFFSET problemMessageEnd


	;Restore used registers
	pop edx
	pop ebx
	pop eax
	
	pop ebp 

	ret 8
showProblem ENDP

;Get user input
;Parameters:
;num: address of the value to store the input
getData PROC
	push ebp
	mov ebp, esp
	
	sub esp, 10 * TYPE BYTE ;Max dword = ~10^9 + null char

	;Save used registers
	push eax
	push ebx
	push ecx
	push edx
	push esi

	getData_num EQU [ebp + TYPE DWORD + TYPE DWORD]
	
	getData_start:
	
	;Get the string
	mov edx, ebp
	sub edx, 4
	mov ecx, 10
	call ReadString 
	
	;Initialize
	mov esi, edx
	xor eax, eax
	cdq
	cld
	mov ecx, getData_num
	mov ebx, 0
	mov [ecx], ebx

	getData_numLoop:

		;Multiply num by 10
		mov ecx, getData_num
		mov ebx, 10
		mov eax, [ecx]
		mul ebx
		mov [ecx], eax
		mov eax, 0
		;Get the next byte
		lodsb
		
		;Stop at the null bit
		cmp al, 0
		je getData_done
		
		;check for invalid characters
		cmp al, '0'
		jl getData_error
		cmp al, '9'
		jg getData_error

		;Convert char to int
		sub al, '0'
		
		mov ecx, getData_num
		
		;Accumulate eax onto num
		add [ecx], eax
		jmp getData_numLoop

	getData_error:
		m_putStr OFFSET invalidNumError
		call WriteChar
		call CrLf
		jmp getData_start
		
	getData_done:
	
	;Roll back one multiply
	mov ebx, 10
	mov ecx, [getData_num]
	mov eax, [ecx]
	div ebx

	;Store at resut
	mov [ecx], eax

	;Restore registers
	pop esi
	pop edx
	pop ecx
	pop ebx
	pop eax
	
	mov esp, ebp
	pop ebp

	ret 4

getData ENDP

;Calculate nCr
;Parameters:
;r: the value of r
;n: the value of n
;result: the address of where to store the result
combination PROC
	push ebp
	mov ebp, esp
	
	;Store used registers
	push eax
	push ebx

	;We will have 3 local variables of size DWORD
	sub esp, TYPE DWORD * 3
	
	combination_r EQU [ebp + TYPE DWORD + TYPE DWORD * 3]
	combination_n EQU [ebp + TYPE DWORD + TYPE DWORD * 2]
	combination_result EQU [ebp + TYPE DWORD + TYPE DWORD]
	
	combination_n_factorial EQU [ebp - TYPE DWORD]
	combination_r_factorial EQU [ebp - TYPE DWORD * 2]
	combination_n_minus_r_factorial EQU [ebp - TYPE DWORD * 3 ]

	;calculate n!
	push combination_n
	lea eax, combination_n_factorial
	push eax
	call factorial

	;calculate r!
	push combination_r
	lea eax, combination_r_factorial
	push eax
	call factorial

	;Calculate (n-r)!
	mov eax, combination_n
	sub eax, combination_r
	push eax
	
	lea eax, combination_n_minus_r_factorial
	push eax
	call factorial

	;calculate r!(n-r)!
	mov eax, combination_r_factorial
	mov ebx, combination_n_minus_r_factorial
	mul ebx

	;calculate n!/(r!(n-r)!)
	cdq
	mov ebx, eax
	mov eax, combination_n_factorial
	div ebx

	;Store at result
	mov ebx, combination_result
	mov [ebx], eax

	;Restore used registers
	pop ebx
	pop eax

	mov esp, ebp
	pop ebp
	ret 12
	

combination ENDP

;Calculate n!
;Parameters:
;n: the value of factorial to calculate
;result: the location of the place to store the result of the factorial
factorial PROC
	push ebp
	mov ebp, esp

	;Store used registers
	push eax
	push ebx

	factorial_result EQU [ebp + TYPE DWORD + TYPE DWORD]
	factorial_n EQU [ebp + TYPE DWORD + TYPE DWORD * 2]

	mov eax, factorial_n
	cmp eax, 0
	jg factorial_recurse

	;Base case
	mov eax, 1
	mov ebx, factorial_result
	mov [ebx], eax ; 0! = 1
	
	jmp factorial_done

	factorial_recurse:
	
	;Recursive step
	dec eax
	push eax
	push factorial_result
	call factorial

	;After final recursion
	mov ebx, factorial_result
	mov ebx, [ebx]
	
	mov eax, factorial_n

	mul ebx
	mov ebx, factorial_result
	mov [ebx], eax

	factorial_done:
		;Restore used registers
		pop ebx
		pop eax

		pop ebp
		ret 8
factorial ENDP

;Display the given answer, the calculation, and wether or not the user is correct.
;Parameters
;answer: the value of user given answer
;r: the value of r
;n: the value of n
;result: the address of where to store the calculated combination
showResult PROC
	push ebp
	mov ebp, esp
	
	;Store used registers
	push eax

	showResult_answer EQU [ebp + TYPE DWORD + TYPE DWORD * 4]
	showResult_r EQU [ebp + TYPE DWORD + TYPE DWORD * 3]

	showResult_n EQU [ebp + TYPE DWORD + TYPE DWORD * 2]
	showResult_result EQU [ebp + TYPE DWORD + TYPE DWORD] 

	;Perform the combination
	push showResult_r
	push showResult_n
	push showResult_result
	call combination

	;Write the user's answer
	mov edx, OFFSET answerMessage
	call WriteString
	
	mov eax, showResult_answer
	call WriteDec
	call CrLf

	;Write the combination result
	mov edx, OFFSET resultMessage
	call WriteString

	mov eax, showResult_result
	mov eax, [eax]
	call WriteDec
	call CrLf

	;Show a message depending on the correctness of the user's answer
	cmp eax, showResult_answer
	je showResult_correct
	
	m_putStrLn OFFSET incorrectMessage
	jmp showResult_done

	showResult_correct:
	m_putStrLn OFFSET correctMessage

	showResult_done:

	;Restore used registers
	pop eax

	pop ebp
	ret 16


showResult ENDP


END main