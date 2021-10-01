;
;       Euler1.asm  -- Solution to Project Euler problem 1
;
; 	Find the sum of all the multiples of 3 or 5 below 1000.
        NAM	Euler1.asm
        TTL	Project Euler problem 1
        OPT	NOG

PUTLIN		EQU	$B99C		; PUT A LINE	Msg in X-1
PUTCR		EQU	$B958		; Put CR $0D

                ORG	$1000		; load address

Start	        LDY	#999		; Get initial dividend
                PSHS    Y               ; Save counter
div_by_3        LDX	#3		; GET DIVISOR
                PSHS	X,Y		; SAVE PARAMETERS IN STACK
                JSR	UREM16		; UNSIGNED DIVIDE, RETURN REMAINDER 
                PULS	D		; GET remainder
                TSTB                    ; is divisible?
                BNE     div_by_5        ; no
                                        ; yes, add to the accumulator
                LDD     ,S              
                LDX     #accum
                JSR     Add24           ; Add 
                BRA     next_number
                
div_by_5        LDY     ,S              
                LDX	#5		; GET DIVISOR
                PSHS	X,Y		; SAVE PARAMETERS IN STACK
                JSR	UREM16		; UNSIGNED DIVIDE, RETURN REMAINDER 
                PULS	D		; GET remainder
                TSTB                    ; is divisible?
                BNE     next_number     ; no
                ; Add multiple
                LDD     ,S              
                LDX     #accum
                JSR     Add24           ; Add 
next_number     LDY     ,S
                LEAY    -1,Y
                BEQ     finish
                STY     ,S
                BRA     div_by_3
        
finish          PULS    Y
                ;LDY	#resultStr
                ;JSR	ConvInt24ToStr

               ; LDX	#resultStr-1	; Basic needs -1 
               ; JSR	PUTLIN		; Print to screen
               ; JSR	PUTCR		; Carriage Return
                RTS			; back to Basic

;
; Data
;
accum		ZMB	3	; 24 bit number accumulated result

resultStr	FCN	"0000000"	; place to store the number as a string string


;	Title:			16-bit division	
;
;	Name:			SDIV16, UDIV16, SREM16, UREM16
;	Purpose:
;				UREM16	Divide 2 unsigned 16-bit words and return a 16-bit unsigned remainder
;
;	Entry:
;
;				TOP OF STACK 
;				High byte of return address 
;				Low  byte of return address 
;				High byte of divisor 
;				Low  byte of divisor 
;				High byte of dividend 
;				Low  byte of dividend
;
;	Exit:
;
;				TOP OF STACK 
;				High byte of result 
;				Low  byte of result
;
;	If no errors then 
;		Carry		:= 0
;	else
;		divide by zero error
;		Carry		:= 1 
;		quotient	:= 0 
;		remainder	:= 0
;
;	Registers Used:		A,B,CC,X,Y
;
;	Time:			Approximately 955 cycles
;
;	Size:
;				Program	145 bytes
;				Data	  3 stack bytes
; 
; UNSIGNED 16-BIT DIVISION, RETURNS REMAINDER
;
UREM16:
; UNSIGNED DIVISION, INDICATE QUOTIENT, REMAINDER BOTH POSITIVE
; 
; CHECK FOR ZERO DIVISOR
; EXIT, INDICATING ERROR, IF FOUND
; 
        LEAX	2,S		; POINT TO DIVISOR 
        LDD	 ,X		; TEST DIVISOR
        BNE	STRTDV		; BRANCH IF DIVISOR NOT ZERO
        STD	2,X		; DIVISOR IS ZERO, SO MAKE RESULT ZERO 
;--	SEC			; INDICATE DIVIDE BY ZERO ERROR
        BRA	EXITDV		; EXIT INDICATING ERROR
;
; DIVIDE UNSIGNED DIVIDEND BY UNSIGNED DIVISOR 
; MEMORY ADDRESSES HOLD BOTH DIVIDEND AND QUOTIENT.
; EACH TIME WE SHIFT THE DIVIDEND ONE BIT LEFT,
; WE ALSO SHIFT A BIT OF THE
; QUOTIENT IN FROM THE CARRY AT THE FAR RIGHT
; AT THE END, THE QUOTIENT HAS REPLACED THE DIVIDEND IN MEMORY
; AND THE REMAINDER IS LEFT IN REGISTER D
; 
STRTDV: LDD	#0		; EXTEND DIVIDEND TO 32 BITS WITH 0 
        LDY	#16		; BIT COUNT = 16 
;
; SHIFT DIVIDEND LEFT WITH ENTERING AT FAR RIGHT 
; 
DIV16:
        ROL	3,X		; SHIFT LOW  BYTE OF DIVIDEND 
        ROL	2,X		; SHIFT NEXT BYTE OF DIVIDEND 
        ROLB			; SHIFT NEXT BYTE OF DIVIDEND 
        ROLA			; SHIFT HIGH BYTE OF DIVIDEND
; 
; DO A TRIAL SUBTRACTION OF DIVISOR FROM DIVIDEND
; IF DIFFERENCE IS NON-NEGATIVE, PERFORM ACTUAL SUBTRACTION.
; IF DIFFERENCE IS NEGATIVE, continue.
;
        CMPD	,X		; TRIAL SUBTRACTION OF DIVISOR
        BCS	DECCNT		; BRANCH IF SUBTRACTION FAILS
        SUBD	,X		; TRIAL SUBTRACTION SUCCEEDED,
                                ; SO SUBTRACT DIVISOR FROM
                                ; DIVIDEND
; 
; UPDATE BIT COUNTER
; CONTINUE THROUGH 16 BITS
; 
DECCNT: LEAY	-1,Y		; CONTINUE UNTIL ALL BITS DONE 
        BNE	DIV16
; 
; SAVE REMAINDER IN STACK
; 
        STD	4,S
; REMOVE PARAMETERS FROM STACK AND EXIT
; 
EXITDV:	LDX	 ,S		; SAVE RETURN ADDRESS 
        LEAS	4,S		; REMOVE PARAMETERS FROM STACK 
        JMP	,X		; EXIT TO RETURN ADDRESS

* Subroutine Add24
*
* Purpose: MultiPrecAdd adds two multi-byte binary numbers
*
* Input: 
* 	16bit number in D.
*	Pointer to 24bit number in X.
* Output: 
*	24 bit number in X. 
*
* Registers affected: A, B, X, Y, U, CC (flags)
Add24   	ANDCC	#%11111110	; clear carry

                ADCB	2,X		; A = A + byte from second number + carry
                STB	2,X		; store result

                ADCA	1,X		; A = A + byte from second number + carry
                STA	1,X		; store result

                LDA     #0
                ADCA	,X		; A = A + byte from second number + carry
                STA	,X		; store result
                RTS

                END     Start
