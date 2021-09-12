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
		jsr	MultiPrecAdd
		rts			; back to Basic

FirstNum	fcb	$45,$32,$11	; 24 bit number
SecondNum	fcb	$32,$11,$54
Result		fcb	0,0,0

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
* Registers affected: B, X, U, CC (flags)


		end	Start		; exec address
