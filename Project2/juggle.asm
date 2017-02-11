; Windows Application                   (juggle.asm)

; This program displays a resizable application window and
; several popup message boxes.
; Thanks to Tom Joyce for creating a prototype
; from which this program was derived.
; Also does a fun juggle program :)

.686p
.MMX
.model flat,stdcall
option casemap:none

;Install masm32 sdk here: http://www.masm32.com/download.htm
include \masm32\include\windows.inc
include \masm32\include\kernel32.inc
include \masm32\include\gdi32.inc
include \masm32\include\user32.inc

includelib \masm32\lib\kernel32.lib
includelib \masm32\lib\gdi32.lib
includelib \masm32\lib\user32.lib



WM_KEYDOWN = 0100h

PADDLE_X_INCREMENT = 20

BALL_INIT_SPEED = 5

BALL_TIMER_UPDATE = 20
BALL_TIMER_ID = 1
ACCEL_TIMER_ID = 2

WINDOW_W = 500
WINDOW_H = 500
;==================== DATA =======================
.data


GreetTitle BYTE "Incredible?",0
GreetText  BYTE "EC: Incredible! It's juggling time!",0

CloseTitle BYTE "You Lose! Bye!", 0
CloseMsg   BYTE "Bye!",0

ErrorTitle  BYTE "Error",0
WindowName  BYTE "Juggle",0
className   BYTE "ASMWin",0

; Define the Application's Window class structure.
MainWin WNDCLASS <NULL,WinProc,NULL,NULL,NULL,NULL,NULL, \
	COLOR_WINDOW,NULL,className>

hdc HDC 0


ps PAINTSTRUCT <>
clientRect RECT <>

msg	      MSG <>
winRect   RECT <>
hMainWnd  DWORD ?
hInstance DWORD ?
;EC: Incredible juggling?

;The paddle should be drawn using Rectangle.
paddleLeftPos SDWORD 0
paddleRightPos DWORD 50

;Init these to client rect
paddleBottomPos DWORD ?
paddleTopPos DWORD ?

ballXVel DWORD BALL_INIT_SPEED
ballYVel DWORD BALL_INIT_SPEED

ballSpeed DWORD BALL_INIT_SPEED

ballYAccel DWORD 1

;Signed so if the ball skips past 0, it can still be bounced.
ballLeftPos SDWORD 10
ballTopPos SDWORD 10 

ballBottomPos DWORD 20
ballRightPos DWORD 20




;=================== CODE =========================
.code
WinMain PROC
; Get a handle to the current process.
	INVOKE GetModuleHandle, NULL
	mov hInstance, eax
	mov MainWin.hInstance, eax

; Load the program's icon and cursor.
	INVOKE LoadIcon, NULL, IDI_APPLICATION
	mov MainWin.hIcon, eax
	INVOKE LoadCursor, NULL, IDC_ARROW
	mov MainWin.hCursor, eax

; Register the window class.
	INVOKE RegisterClass, ADDR MainWin
	.IF eax == 0
	  call ErrorHandler
	  jmp Exit_Program
	.ENDIF

; Create the application's main window.
; Returns a handle to the main window in EAX.
	INVOKE CreateWindowEx, 0, ADDR className,
	  ADDR WindowName, 00C00000h,
	  CW_USEDEFAULT,CW_USEDEFAULT,WINDOW_W,
	  WINDOW_H,NULL,NULL,hInstance,NULL
	mov hMainWnd,eax

; If CreateWindowEx failed, display a message & exit.
	.IF eax == 0
	  call ErrorHandler
	  jmp  Exit_Program
	.ENDIF

; Show and draw the window.
	INVOKE ShowWindow, hMainWnd, SW_SHOW
	INVOKE UpdateWindow, hMainWnd

; Display a greeting message.
	INVOKE MessageBox, hMainWnd, ADDR GreetText,
	  ADDR GreetTitle, MB_OK

;Timer to update the ball.
	INVOKE SetTimer, hMainWnd, BALL_TIMER_ID, BALL_TIMER_UPDATE, 0
;Timer to update ball acceleration
	INVOKE SetTimer, hMainWnd, ACCEL_TIMER_ID, 400, 0

;Init paddle position
	INVOKE GetClientRect, hMainWnd, ADDR clientRect
	
	mov eax, clientRect.bottom
	mov paddleBottomPos, eax

	mov eax, paddleBottomPos
	sub eax, 10
	mov paddleTopPos, eax

; Begin the program's message-handling loop.
Message_Loop:
	; Get next message from the queue.
	INVOKE GetMessage, ADDR msg, NULL,NULL,NULL

	; Quit if no more messages.
	.IF eax == 0
	  jmp Exit_Program
	.ENDIF

	; Relay the message to the program's WinProc.
	INVOKE DispatchMessage, ADDR msg
	jmp Message_Loop

Exit_Program:
	  INVOKE ExitProcess,0
WinMain ENDP

;-----------------------------------------------------
WinProc PROC,
	hWnd:DWORD, localMsg:DWORD, wParam:DWORD, lParam:DWORD
; The application's message handler, which handles
; application-specific messages. All other messages
; are forwarded to the default Windows message
; handler.
;-----------------------------------------------------
	
	mov eax, localMsg
	
	.IF eax == WM_KEYDOWN		;Key pressed
	
	  ;Get client rect for bounds checking
	  INVOKE GetClientRect, hWnd, ADDR clientRect

	  cmp wParam, VK_RIGHT
	  je paddleRight
	  cmp wParam, VK_LEFT
	  je paddleLeft 
	  jmp done

	  paddleRight:
		mov eax, clientRect.right
		cmp paddleRightPos, eax
		jge done

		add paddleLeftPos, PADDLE_X_INCREMENT
		add paddleRightPos, PADDLE_X_INCREMENT
		
		jmp done
	  paddleLeft:
		cmp paddleLeftPos, 0
		
		jle done
		
		sub paddleLeftPos, PADDLE_X_INCREMENT
		sub paddleRightPos, PADDLE_X_INCREMENT

	  done:
	  
	  ;Force a redraw
      INVOKE InvalidateRect, hWnd, 0, 0
	  
	  jmp WinProcExit
	.ELSEIF eax == WM_CLOSE		; close window?
	  INVOKE MessageBox, hWnd, ADDR CloseMsg,
	    ADDR WindowName, MB_OK
	  INVOKE PostQuitMessage,0
	  jmp WinProcExit
	.ELSEIF eax == WM_PAINT
		INVOKE BeginPaint, hWnd, ADDR ps
		
		mov hdc, eax
		;Draw background
		INVOKE FillRect, hdc, ADDR ps.rcPaint, 0FFFFFFFFh
		
		;Draw paddle
		INVOKE SetBkColor, hdc, 00000000h
		INVOKE CreateSolidBrush, 00000000h
		INVOKE SelectObject, hdc, eax
		INVOKE Rectangle, hdc, paddleLeftPos, paddleTopPos, paddleRightPos, paddleBottomPos
		
		;Draw ball
		INVOKE SetBkColor, hdc, 00000000h
		INVOKE CreateSolidBrush, 00000000h
		INVOKE SelectObject, hdc, eax
		INVOKE Rectangle, hdc, ballLeftPos, ballTopPos, ballRightPos, ballBottomPos
	
		INVOKE EndPaint, hWnd, ADDR ps
	.ELSEIF eax == WM_TIMER

		mov eax, wParam 
		cmp wParam, BALL_TIMER_ID
		je ballUpdate
			;Account for gravity
			mov eax, ballYVel
			add eax, ballYAccel
			mov ballYVel, eax
				
		ballUpdate:
			;Get client rect for bounds checking
			INVOKE GetClientRect, hWnd, ADDR clientRect

			;Check for collisions on non-losing bounds
			mov eax, clientRect.right
			cmp ballRightPos, eax
			jge bounce
			cmp ballLeftPos, 0
			jle bounce
			cmp ballTopPos, 0
			jle bounceTop
			jmp checkPaddleCollision
		


			bounce:
				neg ballXVel
				;mov ballXVel, BALL_INIT_SPEED
				jmp checkPaddleCollision
	
			bounceTop:
				neg ballYVel

				;Don't need to check paddle collision if at top
				jmp updatePosition
	
			checkPaddleCollision:

				;If the ball isn't below the paddle, then it definitely isn't touching the bottom
				mov eax, ballBottomPos
				cmp eax, paddleTopPos
				jl updatePosition
			
				;Check if ball within the right side of the paddle			
				mov eax, ballLeftPos
				cmp eax, paddleRightPos
			
				;The ball is too far right to be colliding
				jg checkLoseCondition 
			
				;Ball is in range of paddleRightPos - 0. Check the opposite direction
				mov eax, ballRightPos
				cmp eax, paddleLeftPos
			
				;Ball is too far left to be collding
				jl checkLoseCondition
				
				;Ball is collding
				;Make things a little harder
				mov eax, ballSpeed
				inc eax
				mov ballSpeed, eax

				mov eax, ballSpeed	
				neg eax
				mov ballYVel, eax
				
				;Bounce left or right depending on which side of the paddle the ball is on
				mov eax, paddleRightPos
				sub eax, ballRightPos
			
				cmp eax, 25
				
				jl paddleBounceLeft
					
					mov eax, ballSpeed
					neg eax

					mov ballXVel, eax

					;We know we aren't losing if we're colliding
					jmp updatePosition
				paddleBounceLeft:
					mov eax, ballSpeed
					mov ballXVel, eax

				;We know we aren't losing if we're colliding
				jmp updatePosition
			checkLoseCondition:
				mov eax, clientRect.bottom
				cmp ballBottomPos, eax
				jl updatePosition
				call quit

			updatePosition:

				mov eax, ballLeftPos
				add eax, ballXVel
				mov ballLeftPos, eax

				mov eax, ballRightPos
				add eax, ballXVel
				mov ballRightPos, eax

				mov eax, ballTopPos
				add eax, ballYVel
				mov ballTopPos, eax

				mov eax, ballBottomPos
				add eax, ballYVel
				mov ballBottomPos, eax

			;Force a redraw
			INVOKE InvalidateRect, hWnd, 0, 0

			jmp WinProcExit

	.ELSE		; other message?
	  INVOKE DefWindowProc, hWnd, localMsg, wParam, lParam
	  jmp WinProcExit
	.ENDIF

WinProcExit:
	ret
WinProc ENDP

;---------------------------------------------------
ErrorHandler PROC
; Display the appropriate system error message.
;---------------------------------------------------
.data
pErrorMsg  DWORD ?		; ptr to error message
messageID  DWORD ?
.code
	INVOKE GetLastError	; Returns message ID in EAX
	mov messageID,eax

	; Get the corresponding message string.
	INVOKE FormatMessage, FORMAT_MESSAGE_ALLOCATE_BUFFER + \
	  FORMAT_MESSAGE_FROM_SYSTEM,NULL,messageID,NULL,
	  ADDR pErrorMsg,NULL,NULL

	; Display the error message.
	INVOKE MessageBox,NULL, pErrorMsg, ADDR ErrorTitle,
	  MB_ICONERROR+MB_OK

	; Free the error message string.
	INVOKE LocalFree, pErrorMsg
	ret
ErrorHandler ENDP

quit PROC
	INVOKE KillTimer, hMainWnd, BALL_TIMER_ID
	INVOKE KillTimer, hMainWnd, ACCEL_TIMER_ID
	INVOKE MessageBox, hMainWnd, ADDR CloseTitle,
	  ADDR CloseMsg, MB_OK

	INVOKE DestroyWindow, hMainWnd
	INVOKE ExitProcess,0
	ret
quit ENDP

END ;WinMain