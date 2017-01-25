TITLE Num Star (NumStar.asm)
; Program Description: Quick test for an exercise
; Author: Tristan Thompson
; Creation Date:
; Revisions:
; Date:
INCLUDE Irvine32.inc
.data
star BYTE "*",0
.code
main PROC

mov ecx, 1
mov ebx, 5

mainLoop:
	mov eax, 1
	
	printNumLoop:
		call WriteDec

		inc eax
		
		cmp eax, ecx
		jle printNumLoop

	sub ebx, ecx
	printStarLoop:
		cmp ebx, 1
		jl donePrintStarLoop
	
		mov edx, OFFSET star
		call WriteString
		
		dec ebx
		
		jmp printStarLoop
	
	donePrintStarLoop:

	inc ecx
	mov ebx, 5
	
	call CrLf

	cmp ecx, 5 
	jle mainLoop

call ReadInt
exit
main ENDP
; (insert additional procedures here)
END main