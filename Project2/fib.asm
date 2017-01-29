TITLE Fibonacci calculator (fib.asm)
; Program Description: Gives introduction. Asks for number in range [1..46]. Prints values up to nth term on a valid number. Says goodbye.
; Author: Tristan Thompson
; Creation Date: 1/24/17
; Revisions: 
; Date: 1/24/17

INCLUDE Irvine32.inc
EXTERN WinMain@0:PROC

FIB_MIN = 1
FIB_MAX = 46

;<insert political joke here>
TERM_LIMIT = 5

.data

introMessage BYTE "This is a Fibonacci calculator and my name is Tristan Thompson! What is your name? ",0
ecMessage BYTE "** EC: I added a juggling game! Just you wait!",0
nameMessage BYTE "Hello, ",0
bang BYTE "!",0
space BYTE "     ",0
fibInputMessage BYTE "Give me a value between 1 and 46: ",0
errorMessage BYTE "No, idiot!",0
byeMessage BYTE "Bye!",0

username BYTE 21 DUP(128)

fibLimit DWORD ?
fibCount DWORD 1

prevTerm DWORD 0


.code

main PROC
	;Give title
	mov edx, OFFSET introMessage
	call WriteString

	;Get username
	mov edx, OFFSET username
	mov ecx, SIZEOF username
	call ReadString
	
	;Say hello to user
	mov edx, OFFSET nameMessage
	call WriteString
	mov edx, OFFSET username
	call WriteString
	mov edx, OFFSET bang
	call WriteString
	call CrLF

	;EC: Juggling
	mov edx, OFFSET ecMessage
	call WriteString
	call CrLf

	;Get fib input untill a valid value is passed
	fibInputLoop:
		mov edx, OFFSET fibInputMessage
		call WriteString

		call ReadInt
		
		cmp eax, FIB_MIN
		jl fail
		cmp eax, FIB_MAX
		jg fail

		jmp fibInputLoopDone

		fail:
			mov edx, OFFSET errorMessage
			call WriteString
			call CrLf
			jmp fibInputLoop
	
	
	fibInputLoopDone:

	
	mov ecx, eax
	mov eax, 1
	fibLoop:

		;write fib value
		call WriteDec
		mov edx, OFFSET space
		call WriteString
		
		inc fibCount

		;Increment fibbonacci sequence
		mov ebx, eax ;Store eax temporarily
		add eax, prevTerm
		mov prevTerm, ebx
		
		;Check if line break needed
		mov edx, fibCount
		cmp edx, TERM_LIMIT	
		jg addLineBreak
		loop fibLoop
		jmp fibLoopDone
		 
		addLineBreak:
			call CrLf
			mov fibCount, 0
		loop fibLoop

	
	fibLoopDone:
	call CrLf
	call WaitMsg

	;EC: It's juggling time!
	call juggle
	
	exit
main ENDP


juggle PROC
	call WinMain@0
juggle ENDP



END main