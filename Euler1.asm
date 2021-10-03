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
                JSR     ADD16_24        ; Add 
                BRA     next_number
                
div_by_5        LDY     ,S              
                LDX	#5		; get divisor
                PSHS	X,Y		; save parameters in stack
                JSR	UREM16		; unsigned divide, return remainder 
                PULS	D		; get remainder
                TSTB                    ; is divisible?
                BNE     next_number     ; no
                ; Add multiple
                LDD     ,S              
                LDX     #accum
                JSR     ADD16_24        ; Add 
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


;	Name:			UREM16
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
; Based on the implementation by Lance A. Leventhal
;
UREM16
; 
; check for zero divisor
; exit, indicating error, if found
; 
                LEAX	2,S		; point to divisor 
                LDD	 ,X		; test divisor
                BNE	strtdv		; branch if divisor not zero
                STD	2,X		; divisor is zero, so make result zero 
                BRA	exitdv		; exit indicating error
;
; divide unsigned dividend by unsigned divisor 
; memory addresses hold both dividend and quotient.
; each time we shift the dividend one bit left,
; we also shift a bit of the
; quotient in from the carry at the far right
; at the end, the quotient has replaced the dividend in memory
; and the remainder is left in register d
; 
strtdv          LDD	#0		; extend dividend to 32 bits with 0 
                LDY	#16		; bit count = 16 
;
; shift dividend left with entering at far right 
; 
div16
                ROL	3,X		; shift low  byte of dividend 
                ROL	2,X		; shift next byte of dividend 
                ROLB			; shift next byte of dividend 
                ROLA			; shift high byte of dividend
; 
; do a trial subtraction of divisor from dividend
; if difference is non-negative, perform actual subtraction.
; if difference is negative, continue.
;
                CMPD	,X		; trial subtraction of divisor
                BCS	deccnt		; branch if subtraction fails
                SUBD	,X		; trial subtraction succeeded,
                                        ; so subtract divisor from
                                        ; dividend
; 
; update bit counter
; continue through 16 bits
; 
deccnt          LEAY	-1,Y		; continue until all bits done 
                BNE	div16
; 
; save remainder in stack
; 
                STD	4,S
; remove parameters from stack and exit
; 
exitdv	        LDX	 ,S		; save return address 
                LEAS	4,S		; remove parameters from stack 
                JMP	,X		; exit to return address


;	Name:			ADD16_24
;	Purpose:
;				Add a 16bit number to a 24bit number in big-endian representation
;
;	Entry:
;
;				Register D: 16bit number
;                               Register X: Pointer to 24bit number
;
;	Exit:
;
;				Sum in number pointed by register X 
;
ADD16_24   	ANDCC	#%11111110	; clear carry

                ADCB	2,X		; B = B + byte from second number + carry
                STB	2,X		; store result

                ADCA	1,X		; A = A + byte from second number + carry
                STA	1,X		; store result

                LDA     #0
                ADCA	,X		; A = A + byte from second number + carry
                STA	,X		; store result
                RTS

                END     Start
