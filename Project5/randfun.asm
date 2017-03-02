TITLE Random Operations (randop.asm)
; Program Description: Create a set of n random numbers, sort it, and find the median value
; Author: Tristan Thompson
; Creation Date: 2/27/17
; Revisions:
; Date: 2/27/17
INCLUDE Irvine32.inc
REQUEST_MIN = 10
REQUEST_MAX = 200

RANDOM_MIN = 100
RANDOM_MAX = 999

.data
introMessage BYTE "My name is Tristan Thompson and this is Random Operations!",0
requestMessage BYTE "Give me a number of random numbers between 10 and 200: ",0
errorMessage BYTE "No, idiot!",0
arrayTitleMessage BYTE "Here are ya random nums boi:",0
request DWORD ?
randomNums DWORD REQUEST_MAX-REQUEST_MIN DUP(?)


.code
main PROC
	call introduction
	
	push OFFSET request
	call getData

	push request
	push OFFSET randomNums
	call fillArray

	push OFFSET randomNums
	push request
	push OFFSET arrayTitleMessage
	call displayList

; (insert executable instructions here)
exit
main ENDP

;Write introMessage
introduction PROC
	mov edx, OFFSET introMessage
	call WriteString
	call CrLf
	ret
introduction ENDP

;Get amount of random numbers to calculate
;Parameters:
;Request: a reference to a variable that holds the amount of numbers to calculate
getData PROC
	push ebp
	mov ebp, esp
	requestAddr EQU [ebp + 8]
	
	requestLoop:
		mov edx, OFFSET requestMessage
		call WriteString
		call ReadInt
		cmp eax, REQUEST_MIN
		jl requestError
		cmp eax, REQUEST_MAX
		jg requestError
		jmp requestDone
		requestError:
			mov edx, OFFSET errorMessage
			call WriteString
			call CrLf
			jmp requestLoop
	requestDone:
	mov esi, requestAddr
	mov [esi], eax
	pop ebp
	ret
getData ENDP

;Fill a given array with random numbers
;Paramters:
;Request: the amount of numbers to generate
;Array: A reference to the array to fill
fillArray PROC
	LOCAL fills:DWORD
	paramRequest EQU [ebp + 12]
	paramArray EQU [ebp + 8]

	mov esi, 0
	mov fills, 0
	mov ebx, paramArray

	fillLoop:
		mov eax, RANDOM_MAX - RANDOM_MIN
		call RandomRange
		add eax, RANDOM_MIN
		
		mov [esi+ebx], eax
		
		add esi, TYPE DWORD
		add fills, 1

		mov eax, fills
		cmp eax, paramRequest
		jg fillDone
		jmp fillLoop

	fillDone:

	leave
	ret
fillArray ENDP

sortList PROC
sortList ENDP

exchangeElements PROC
exchangeElements ENDP

displayMedian PROC
displayMedian ENDP

;Display a list
;Parameters:
;Array: the array to display
;Request: The amount of elements to display
;Title: A string reference to a message to display
displayList PROC
	LOCAL displays:DWORD
 	paramArrayDisplay EQU [ebx + 16]
	paramDisplayAmount EQU [ebx + 12]
	paramArrayTitle EQU [ebx + 8]

	mov displays, 0

	mov edx, paramArrayTitle
	call WriteString
	call CrLf

	mov ecx, paramDisplayAmount

	mov ebx, 0
	mov esi, paramArrayDisplay

	displayLoop:	

		;Write current element
		mov eax, [esi + ebx]
		call WriteDec
		xor eax, eax
		mov al, ','
		call WriteChar
		mov al, ' ' 
		call WriteChar		
		
		;Increment index and count
		add displays, 1
		add ebx, 4

		mov eax, displays
		cmp eax, ecx
		je displayLoopDone
		
	displayLoopDone:

	leave
	ret
displayList ENDP


; (insert additional procedures here)
END main