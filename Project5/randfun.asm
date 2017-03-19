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

NUMS_PER_LINE = 10

.data
introMessage BYTE "My name is Tristan Thompson and this is Random Operations!",0
requestMessage BYTE "Give me a number of random numbers between 10 and 200: ",0
errorMessage BYTE "No, idiot!",0
arrayUnsortedTitleMessage BYTE "Unsorted numbers:",0
arraySortedTitleMessage BYTE "Sorted numbers:",0
arrayMedianMessage BYTE "Median: ",0
request DWORD ?
randomNums DWORD REQUEST_MAX + 1 DUP(?)

spaces BYTE "   ",0

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
	push OFFSET arrayUnsortedTitleMessage
	call displayList

	push OFFSET randomNums
	push request
	call sortList

	push OFFSET randomNums
	push request
	push OFFSET arraySortedTitleMessage
	call displayList

	push OFFSET randomNums
	push request
	call displayMedian

	call ReadInt
; (insert executable instructions here)
exit
main ENDP

;Write introMessage
introduction PROC USES edx
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
	requestAddr EQU [ebp + TYPE DWORD * 2]
	
	requestLoop:
		mov edx, OFFSET requestMessage
		call WriteString
		call ReadInt

		;Check for errors
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

	;Store request into given address
	mov esi, requestAddr
	mov [esi], eax
	
	pop ebp
	ret TYPE DWORD
getData ENDP

;Fill a given array with random numbers
;Paramters:
;Request: the amount of numbers to generate
;Array: A reference to the array to fill
fillArray PROC 
	push ebp 
	mov ebp, esp
	sub esp , TYPE DWORD

	fills EQU [ebp - 4]
	paramRequest EQU [ebp + 12]
	paramArray EQU [ebp + 8]

	mov esi, 0

	mov eax, 0
	mov fills, eax	

	mov ebx, paramArray

	call Randomize

	fillLoop:
		;100-999 = 0-899 + 100
		mov eax, RANDOM_MAX - RANDOM_MIN
		call RandomRange
		add eax, RANDOM_MIN
		
		mov [esi+ebx], eax
		
		;Increment eax and fills
		add esi, TYPE DWORD
		mov eax, fills
		add eax, 1
		mov fills, eax

		mov eax, fills
		cmp eax, paramRequest
		jg fillDone
		jmp fillLoop

	fillDone:
	mov esp, ebp
	pop ebp
	
	ret TYPE DWORD * 2
fillArray ENDP

;Sort a list
;Parameters:
;Array: a reference to the array to sort
;Request: the size of the array
sortList PROC
	push ebp
	mov ebp, esp
	sub esp, 4
	swapped EQU [ebp - 4]
	sortArray EQU [ebp + 12]
	sortRequest EQU [ebp + 8]

	;Make sortRequest in terms of bytes for ease of iteration
	mov eax, sortRequest
	mov ebx, TYPE DWORD
	mul ebx
	mov sortRequest, eax

	mov eax, 0
	mov [swapped], eax

	mov esi, sortArray
	
	sortLoop:
		mov eax, TYPE DWORD ;1st index
		mov ebx, 0 ;0th index
		mov edx, 0
		mov [swapped], edx
		sortIteration:
			mov edx, [esi + eax]	
			cmp edx, [esi + ebx]
			jle iterate

			mov edx, 1
			mov [swapped], edx

			;Store relevant registers
			push eax
			push ebx

			;Push the position of array[i] and array[i-1]
			mov edx, esi
			add edx, eax
			push edx

			mov edx, esi
			add edx, ebx
			push edx

			call exchangeElements

			;Restore relevant registers
			pop ebx
			pop eax 

			iterate:
				add eax, TYPE DWORD
				add ebx, TYPE DWORD
				cmp eax, sortRequest
				jg doneIteration
				jmp sortIteration
				doneIteration:
					;If there were no swaps, then the list is properly sorted.
					mov edx, [swapped]
					cmp edx, 0
					jg sortLoop
	mov esp, ebp
	pop ebp
	ret TYPE DWORD * 2
sortList ENDP

;Exchange two elements in an array
;Parameters:
;array[i]: A reference to the ith element to swap
;array[j]: A reference to the jth element to swap
exchangeElements PROC 
	push ebp
	mov ebp, esp
	arrayI EQU [ebp + 12]
	arrayJ EQU [ebp + 8]
	
	;save arrayJ
	mov eax, arrayJ
	mov eax, [eax]
	push eax
	
	;Write arrayI to arrayJ
	mov eax, arrayJ

	;Get the value of arrayI
	mov ebx, arrayI
	mov ebx, [ebx]
	
	mov [eax], ebx

	;Write araryJ to arrayI
	
	;Get the value of arrayJ
	pop ebx	
	mov eax, arrayI
	mov [eax], ebx

	pop ebp
	ret TYPE DWORD * 2
exchangeElements ENDP

;Calculate and display the median of a list.
;Parameters:
;Array: the array to calculate on
;Request: the size of the array
displayMedian PROC
	push ebp
	mov ebp, esp
	medianArray EQU [ebp + 12]
	medianRequest EQU [ebp + 8]
	
	mov esi, medianArray

	mov edx, OFFSET arrayMedianMessage
	call WriteString


	;Calculate midpoint in bytes
	cdq
	mov eax, medianRequest
	mov ebx, 2
	div ebx
	
	;eax is off by one due to the way indexes are counted.
	dec eax 

	mov ebx, TYPE DWORD
	mul ebx
	
	cmp edx, 0
	jg displayOdd

	;if the request is even, we need to take the average of the two values around the midpoint.
	mov ebx, eax
	add ebx, TYPE DWORD
	
	mov eax, [esi + eax]
	mov ebx, [esi + ebx]
	add eax, ebx
	mov ebx, 2
	div ebx
	jmp done

	;if the request is odd, we can directly display the midpoint
	displayOdd:
		add eax, TYPE DWORD
		mov eax, [esi + eax]
		
	done:
	call WriteDec

	pop ebx
	ret TYPE DWORD * 2
displayMedian ENDP

;Display a list
;Parameters:
;Array: the array to display
;Request: The amount of elements to display
;Title: A string reference to a message to display
displayList PROC 
	push ebp 
	mov ebp, esp
	sub esp , TYPE DWORD * 2

	displays EQU [ebp - TYPE DWORD]
	lineDisplays EQU [ebp - TYPE DWORD * 2]

 	paramArrayDisplay EQU [ebp + 16]
	paramDisplayAmount EQU [ebp + 12]
	paramArrayTitle EQU [ebp + 8]

	mov eax, 0
	mov displays, eax
	mov lineDisplays, eax

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

		mov edx, OFFSET spaces
		call WriteString
		
		;Increment index and count

		mov eax, displays
		add eax, 1
		mov displays, eax

		add ebx, 4

		;Increment line displays and check if at limit
		mov eax, lineDisplays
		add eax, 1
		mov lineDisplays, eax

		cmp eax, NUMS_PER_LINE
		jl checkDone
		
		call CrLf
		mov eax, 0
		mov lineDisplays, eax

		checkDone:
			mov eax, displays
			cmp eax, ecx
			je displayLoopDone
			jmp displayLoop
	displayLoopDone:
	call CrLf

	mov esp, ebp
	pop ebp
	ret TYPE DWORD * 3
displayList ENDP


; (insert additional procedures here)
END main