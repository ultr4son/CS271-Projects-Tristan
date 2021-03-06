TITLE Intro (Intro.asm)
; Program Description: Displays my name and program title, and performs all of the basic arithmetical operations on two user defined numbers.
; Author: Tristan Thompson
; Creation Date: 1/12/17
; Revisions:
; Date: 1/12/17
INCLUDE Irvine32.inc
.data

;Strings to display
nameAndTitle BYTE "My name is Tristan, and this is Intro!",0
instructions BYTE "Give me a number",0
repeatMessage BYTE "Go again? y for yes other for no.",0

sumMessage BYTE "sum: ",0
differenceMessage BYTE "difference: ",0
productMessage BYTE "product: ",0
quotientMessage BYTE "quotient: ",0
fpQuotientMessage BYTE "fp quotient: ",0
remainderMessage BYTE "remainder: ",0

lessThanMessage BYTE "The first number is less than the second!",0
greaterThanMessage Byte "The first number is greater than the second!",0

byeMessage BYTE "bye!",0


;Holders for user values
n1 DWORD ?
n2 DWORD ?

;Holders for arithmetic operations
sum DWORD ?
difference DWORD ?
product DWORD ?
quotient DWORD ?
remainder DWORD ?

quotientFloat REAL8 ?

;For floating point print
significand DWORD ?
exponent SDWORD ?
toPrint BYTE ?
dot BYTE ".",0
zero BYTE "0",0

.code
main PROC

	;Display name and title
	mov edx, OFFSET nameAndTitle
	call WriteString
	call CrLf

;EC: repeat untill quit
operationBody:
	;Get first number
	mov edx, OFFSET instructions
	call WriteString
	call CrLf

	call ReadInt ;Value now in eax
	mov n1, eax ;Keep a copy for math

	;Get second number
	mov edx, OFFSET instructions
	call WriteString
	call CrLf

	call ReadInt
	mov n2, eax

	;EC: gt\lt operation
	mov eax, n1
	cmp eax, n2
	
	;IF n2 > n1 print lessThanMessage
	;ELSE print greaterThanMessage
	jl lessThan

	mov edx, OFFSET greaterThanMessage
	call WriteString
	jmp done

	lessThan:
		mov edx, OFFSET lessThanMessage
		call WriteString
	
	;Regardles of outcome, print CrLf
	done:
	call CrLf

	;sum operation (n1+n2)
	mov eax, n1
	add eax, n2
	mov sum, eax

	;difference operation (n1-n2)
	mov eax, n1
	sub eax, n2
	mov difference, eax


	;product operation (n1*n2)
	mov eax, n1
	mul n2
	mov product, eax

	;quotient/remainder operation (n1//n2)/(n1%n2)
	mov eax, n1
	div n2
	mov quotient, eax
	mov remainder, edx

	;EC: floating point quotient (n1/n2)
	finit
	;Load both values into FPU
	fild n1
	fild n2

	;divide and store result into st0
	fdivp 

	;Pop and store in quotientFloat
	fstp quotientFloat

	;Display each result
	
	;sum
	mov edx, OFFSET sumMessage
	mov eax, sum
	call printVal

	;difference
	mov edx, OFFSET differenceMessage
	mov eax, difference
	call printVal

	;product
	mov edx, OFFSET productMessage
	mov eax, product
	call printVal

	;quotient
	mov edx, OFFSET quotientMessage
	mov eax, quotient
	call printVal

	;EC: fp quotient
	mov edx, OFFSET fpQuotientMessage
	call WriteString
	fld quotientFloat	
	call WriteFloat
	call CrLf

	;remainder
	mov edx, OFFSET remainderMessage
	mov eax, remainder
	call printVal

	;EC: repeat untill quit
	mov edx, OFFSET repeatMessage
	call WriteString
	call CrLF
	call ReadChar

	cmp al, 'y'
	je operationBody


	;bye!
	mov edx, OFFSET byeMessage
	call WriteString
	call CrLf
	
	;Keep the window open untill enter is pressed.
	call ReadInt 
	exit
main ENDP

;Prints a message and then a value.
;edx: message offset
;eax: number
printVal PROC
	call WriteString
	call WriteInt
	call CrLf 
	ret
printVal ENDP





END main