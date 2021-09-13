*
*       Euler1.asm  -- Solution to Project Euler problem 1
*
        NAM	Euler1.asm
        TTL	Project Euler problem 1
        OPT	NOG

GETCHR		equ	$A000		; GET 1 Char jsr[GETCHR]
PUTLIN		equ	$B99C		; PUT A LINE	Msg in X-1
PUTCR		equ	$B958		; Put CR $0D

		org	$1000		; load address

Start		ldx	#FirstNum
		ldy	#SecondNum
		ldu	#Result
		ldb	#3
		jsr	ConvInt24ToStr
		rts			; back to Basic

FirstNum	fcb	$1B,$36,$4D	; 24 bit number
SecondNum	fcb	$00,$10,$02
Result		fcb	0,0,0,0,0

* Subroutine MultiPrecAdd
*
* Purpose: MultiPrecAdd adds two multi-byte binary numbers
*
* Input: 
* 	Least Significant Byte (LSB) of numbers starting addresses in index X and Y.
*	Length of numbers in bytes in B.
* Output: 
*	LSB of result starting address in index U. 
*
* Registers affected: A, B, X, Y, U, CC (flags)
MultiPrecAdd	andcc	#%11111110	; clear carry
AddByte		lda	,X+		; get byte from first number
		adca	,Y+		; A = A + byte from second number + carry
		sta	,U+		; store result
		decb			; all bytes added?
		bne	AddByte
		rts

* Subroutine MultiPrecSub
*
* Purpose: MultiPrecSub substracts two multi-byte binary numbers
*
* Input: 
* 	Least Significant Byte (LSB) of numbers starting addresses in index X and Y.
*	Length of numbers in bytes in B.
* Output: 
*	LSB of result (X - Y) starting address in index U. 
*
* Registers affected: A, B, X, Y, U, CC (flags)
MultiPrecSub	andcc	#%11111110	; clear carry
SubByte		lda	,X+		; get byte from first number
		sbca	,Y+		; A = A - byte from second number + carry
		sta	,U+		; store result
		decb			; all bytes added?
		bne	SubByte
		rts

* Subroutine ConvInt24ToStr
*
* Purpose: ConvInt24ToStr converts a multi-byte binary number to a string
*
* Input: 
* 	Least Significant Byte (LSB) of number starting addresses in index X.
*	First ASCII character of result starting address in index U.
*	Length of number in bytes in B.
* Output
*
* Registers affected: B, X, Y, U, CC (flags)
ConvInt24ToStr	ldy	#TempConv
		lda	,X+
		sta	,Y+
		lda	,X+
		sta	,Y+
		lda	,X+
		sta	,Y+
		ldx	#TempConv
		ldu	#TempConv
		ldb	#3
		ldy	#TableExp10
		lda	#0
		sta	Count
Sub1		jsr	MultiPrecSub
		bcs	AddBack
		lda	Count
		inca
		sta	Count
		
		ldx	#TempConv
		ldu	#TempConv
		ldb	#3
		ldy	#TableExp10
		bra	Sub1

AddBack		ldx	#TempConv
		ldu	#TempConv
		ldb	#3
		ldy	#TableExp10
		jsr	MultiPrecSub
		rts
Count		fcb	0
TempConv	fcb	0,0,0	
TableExp10	fcb	$40,$42,$0F # Exp10(6) = 1000000
		fcb	$A0,$86,$01 # Exp10(5) =  100000
		fcb	$A0,$86,$01 # Exp10(4) =   10000
		fcb	$A0,$86,$01 # Exp10(3) =    1000
		fcb	$A0,$86,$01 # Exp10(2) =     100
		fcb	$A0,$86,$01 # Exp10(1) =      10
		end	Start		; exec address
