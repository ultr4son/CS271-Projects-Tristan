TITLE Fibonacci calculator (fib.asm)
; Program Description: Gives introduction. Asks for number in range [1..46]. Prints values up to nth term on a valid number. Says goodbye.
; Author: Tristan Thompson
; Creation Date: 1/24/17
; Revisions: 
; Date: 1/24/17
INCLUDE Irvine32.inc
FIB_MIN = 1
FIB_MAX = 46

.data
introMessage BYTE "This is a Fibonacci calculator! What is your name?",0
nameMessage BYTE "Hello, ",0
bang BYTE "!",0
fibInputMessage BYTE "Give me a value between 1 and 46",0
errorMessage BYTE "No, idiot!",0

username BYTE 0 DUP(128)
fibTerms DWORD ?

.code
main PROC
	mov edx, OFFSET introMessage
	call WriteString
exit
main ENDP
; (insert additional procedures here)
END main