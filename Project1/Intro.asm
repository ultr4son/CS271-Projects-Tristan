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
sumMessage BYTE "sum:\n",0
differenceMessage BYTE "difference:\n",0
productMessage BYTE "product:\n",0
quotientMessage BYTE "quotient\n",0
remainderMessage BYTE "remainder:\n",0
byeMessage BYTE "bye!",0

;Holders for arithmetic operations
sum DWORD ?
difference DWORD ?
product DWORD ?
quotient DWORD ?
remainder DWORD ?

.code
main PROC

exit
main ENDP
; (insert additional procedures here)
END main