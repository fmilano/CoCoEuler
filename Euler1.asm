*
*       Euler1.asm  -- Solution to Project Euler problem 1
*
        NAM	Euler1.asm
        TTL	Project Euler problem 1
        OPT	NOG

PUTLIN		equ	$B99C		; PUT A LINE	Msg in X-1
PUTCR		equ	$B958		; Put CR $0D

		org	$1000		; load address

Start		ldx	#FirstNum
		ldy	#SecondNum
		ldu	#Result
		ldb	#3

		ldx	#FirstNum
		ldy	#ResultStr
		jsr	ConvInt24ToStr

		ldx	#ResultStr-1	; Basic needs -1 
		jsr	PUTLIN		; Print to screen
		jsr	PUTCR		; Carriage Return
		rts			; back to Basic

FirstNum	fcb	$0D,$10,$5A	; 24 bit number
SecondNum	fcb	$00,$10,$02
Result		fcb	0,0,0,0,0

ResultStr	fcn	"0000000"	; place to store the number as a string string


* Subroutine MultiPrecAdd
*
* Purpose: MultiPrecAdd adds two multi-byte binary numbers
*
* Input: 
* 	Least Significant Byte (LSB, little endian) of numbers starting addresses in index X and Y.
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
*	Address to write the string (7 characters positions) on register Y. 
* Output:
*	First ASCII character of result starting address in index U.
*
* A 24 bit number occupies a maximum of 7 decimal digits.
*
* Registers affected: A, B, X, Y, U, CC (flags)
ConvInt24ToStr	sty	OutputPtr
		ldy	#TempConv
		ldb	#3		;copy the value to convert
loop1		lda	,X+	
		sta	,Y+
		decb
		bne	loop1

		ldb	#6		;initialize local variables
		stb	Digits
		ldb	#0
		stb	OutputOffset
		stb	TableOffset

convdigit	ldb	#0		;convert digit
		stb	Count
		ldb	TableOffset
		ldx	#TableExp10
		leay	B,X
		sty	TablePtr		
		ldx	#TempConv
		ldu	#TempConv
		ldb	#3	
sub1		jsr	MultiPrecSub
		bcs	addBack
		lda	Count
		inca
		sta	Count
		
		ldx	#TempConv
		ldu	#TempConv
		ldb	#3
		ldy	TablePtr
		bra	sub1

addBack		ldx	#TempConv
		ldu	#TempConv
		ldb	#3
		ldy	TablePtr
		jsr	MultiPrecAdd
		
		lda	#3
		adda	TableOffset
		sta	TableOffset
		
		lda	#$30
		adda	Count
		ldx	OutputPtr
		ldb	OutputOffset
		sta	B,X
		incb
		stb	OutputOffset
		cmpb	#6
		bne	convdigit
		
		lda	#$30		; convert the unit
		adda	TempConv
		sta	B,X
		ldu	OutputPtr
		rts
Digits		fcb	0	;number of digits (5)
Count		fcb	0	;count for current digit
TempConv	fcb	0,0,0	;value to convert
OutputOffset	fcb	0	;digit being converted

OutputPtr	fdb	0	;output string

TableOffset	fcb	0	;offset in conversion table
TablePtr	fdb	0

TableExp10	fcb	$40,$42,$0F # Exp10(6) = 1000000
		fcb	$A0,$86,$01 # Exp10(5) =  100000
		fcb	$10,$27,$00 # Exp10(4) =   10000
		fcb	$E8,$03,$00 # Exp10(3) =    1000
		fcb	$64,$00,$00 # Exp10(2) =     100
		fcb	$0A,$0,$00 # Exp10(1) =      10
		end	Start		; exec address
