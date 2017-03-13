TITLE Program Template (Template.asm)
; Program Description:
; Author:
; Creation Date:
; Revisions:
; Date:
INCLUDE Irvine32.inc
.data
; (insert variables here)
.code
main PROC
; (insert executable instructions here)
exit
main ENDP
readNum PROC
	push ebp
	mov ebp, esp
	string TEXTEQU [ebp-8]
	
	;Get the string
	mov edx, string
	call ReadString 


readNum ENDP
; (insert additional procedures here)
END main