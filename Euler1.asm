;
;       Euler1.asm  -- Solution to Project Euler problem 1
;
;       Find the sum of all the multiples of 3 or 5 below 1000.

PUTLIN          EQU     $B99C           ; PUT A LINE   Msg in X-1
PUTCR           EQU     $B958           ; Put CR $0D

                ORG     $1000           ; load address

Start           LDY     #999            ; Get initial dividend
                PSHS    Y               ; Save counter
div_by_3        LDX     #3              ; GET DIVISOR
                PSHS    X,Y             ; SAVE PARAMETERS IN STACK
                JSR     UREM16          ; UNSIGNED DIVIDE, RETURN REMAINDER 
                PULS    D               ; GET remainder
                TSTB                    ; is divisible?
                BNE     div_by_5        ; no
                                        ; yes, add to the accumulator
                LDD     ,S              
                LDX     #accum
                JSR     ADD16_24        ; Add 
                BRA     next_number
                
div_by_5        LDY     ,S              
                LDX     #5              ; get divisor
                PSHS    X,Y             ; save parameters in stack
                JSR     UREM16          ; unsigned divide, return remainder 
                PULS    D               ; get remainder
                TSTB                    ; is divisible?
                BNE     next_number     ; no
                ; Add multiple
                LDD     ,S              
                LDX     #accum
                JSR     ADD16_24         
next_number     LDY     ,S
                LEAY    -1,Y
                BEQ     finish
                STY     ,S
                BRA     div_by_3
        
finish          LDX     #accum
                LDY     #result_str
                JSR     CONV_INT24_STR

                LDX     #result_str-1   ; Basic needs -1 
                JSR     PUTLIN          ; Print to screen
                JSR     PUTCR           ; Carriage Return
                PULS    X
                RTS                     ; back to Basic

;
; Data
;
accum      ZMB   3   ; 24 bit number accumulated result

result_str   FCN   "0000000"   ; place to store the number as a string string


;       Name:           UREM16
;       Purpose:
;                       Divide 2 unsigned 16-bit words and return a 16-bit unsigned remainder
;
;       Entry:
;
;            TOP OF STACK 
;            High byte of return address 
;            Low  byte of return address 
;            High byte of divisor 
;            Low  byte of divisor 
;            High byte of dividend 
;            Low  byte of dividend
;
;       Exit:
;
;            TOP OF STACK 
;            High byte of result 
;            Low  byte of result
;
;       If no errors then 
;               Carry      := 0
;       else
;               divide by zero error
;               Carry      := 1 
;               quotient   := 0 
;               remainder   := 0
;
;       Registers Used:      A,B,CC,X,Y
;
; Based on the implementation by Lance A. Leventhal
;

; 
; check for zero divisor
; exit, indicating error, if found
; 
UREM16:         LEAX    2,S             ; point to divisor 
                LDD     ,X              ; test divisor
                BNE     strtdv          ; branch if divisor not zero
                STD     2,X             ; divisor is zero, so make result zero 
                BRA     exitdv          ; exit indicating error
;
; divide unsigned dividend by unsigned divisor 
; memory addresses hold both dividend and quotient.
; each time we shift the dividend one bit left,
; we also shift a bit of the
; quotient in from the carry at the far right
; at the end, the quotient has replaced the dividend in memory
; and the remainder is left in register d
; 
strtdv          LDD     #0              ; extend dividend to 32 bits with 0 
                LDY     #16             ; bit count = 16 
;
; shift dividend left with entering at far right 
; 
div16
                ROL     3,X             ; shift low  byte of dividend 
                ROL     2,X             ; shift next byte of dividend 
                ROLB                    ; shift next byte of dividend 
                ROLA                    ; shift high byte of dividend
; 
; do a trial subtraction of divisor from dividend
; if difference is non-negative, perform actual subtraction.
; if difference is negative, continue.
;
                CMPD    ,X              ; trial subtraction of divisor
                BCS     deccnt          ; branch if subtraction fails
                SUBD    ,X              ; trial subtraction succeeded,
                                        ; so subtract divisor from
                                        ; dividend
; 
; update bit counter
; continue through 16 bits
; 
deccnt          LEAY    -1,Y            ; continue until all bits done 
                BNE     div16
; 
; save remainder in stack
; 
                STD     4,S
; remove parameters from stack and exit
; 
exitdv          LDX     ,S      ; save return address 
                LEAS    4,S      ; remove parameters from stack 
                JMP     ,X      ; exit to return address


;       Name:           ADD16_24
;       Purpose:
;                       Add a 16-bit number to a 24-bit number in big-endian representation
;
;       Entry:
;
;               Register D = 16-bit number
;               Register X = Pointer to 24-bit number
;
;       Exit:
;               Register X = Pointer to 24-bit result 
;
ADD16_24:       ANDCC   #%11111110   ; clear carry

                ADCB    2,X             ; B = B + byte from second number + carry
                STB     2,X             ; store result

                ADCA    1,X             ; A = A + byte from second number + carry
                STA     1,X             ; store result

                LDA     #0
                ADCA    ,X              ; A = A + byte from second number + carry
                STA     ,X              ; store result
                RTS

;       Name:           ADD24
;       Purpose:
;                       Add two 24-bit numbers in big-endian representation
;
;       Entry:
;
;               Register X = Pointer to 24-bit number
;               Register Y = Pointer to 24-bit number
;
;       Exit:
;               Register U = Pointer to 24-bit result 
;
ADD24:          ANDCC   #%11111110      ; clear carry

                LDA     2,X
                ADCA    2,Y             ; A = A + byte from second number + carry
                STA     2,U             ; store result

                LDA     1,X
                ADCA    1,Y             ; A = A + byte from second number + carry
                STA     1,U             ; store result

                LDA     ,X
                ADCA    ,Y              ; A = A + byte from second number + carry
                STA     ,U              ; store result
                RTS

;       Name:           SUB24
;       Purpose:
;                       Substract two 24-bit numbers in big-endian representation
;
;       Entry:
;
;               Register X = Pointer to 24-bit number (minuend)
;               Register Y = Pointer to 24-bit number (substraend)
;
;       Exit:
;               Register Y = Pointer to 24-bit result 
;
SUB24:          ANDCC   #%11111110      ; clear carry

                LDA     2,X             ; get byte from first number
                SBCA    2,Y             ; A = A - byte from second number - carry
                STA     2,U              ; store result

                LDA     1,X             ; get byte from first number
                SBCA    1,Y             ; A = A - byte from second number - carry
                STA     1,U              ; store result

                LDA     ,X             ; get byte from first number
                SBCA    ,Y             ; A = A - byte from second number - carry
                STA     ,U              ; store result
                RTS


;       Name:           CONV_INT24_STR
;       Purpose:
;                       Converts a 24-bit binary number to a string of ASCII decimal digits
;
;       Entry:
;
;            Register X = Pointer to 24-bit number 
;            Register Y = Pointer destination memory space for ASCII string
;
;       Exit:
;            Register Y = Pointer to ASCII string 
;
CONV_INT24_STR: STY     OutputPtr
                LDY     #TempConv
                LDB     #3              ; copy the value to convert
loop1           LDA     ,X+   
                STA     ,Y+
                DECB
                BNE     loop1

                LDB     #6              ; initialize local variables
                STB     Digits
                LDB     #0
                STB     OutputOffset
                STB     TableOffset

convdigit       LDB     #0              ; convert digit
                STB     Count
                LDB     TableOffset
                LDX     #TableExp10
                LEAY    B,X
                STY     TablePtr      
                LDX     #TempConv
                LDU     #TempConv
sub1            JSR     SUB24
                BCS     addBack
                LDA     Count
                INCA
                STA     Count
                
                LDX     #TempConv
                LDU     #TempConv
                LDY     TablePtr
                BRA     sub1

addBack         LDX     #TempConv
                LDU     #TempConv
                LDY     TablePtr
                JSR     ADD24
                
                LDA     #3
                ADDA    TableOffset
                STA     TableOffset
                
                LDA     #$30
                ADDA    Count
                LDX     OutputPtr
                LDB     OutputOffset
                STA     B,X
                INCB
                STB     OutputOffset
                CMPB    #6
                BNE     convdigit
                
                LDA     #$30            ; convert the unit
                LDY     #TempConv
                ADDA    2,Y
                STA     B,X
                LDY     OutputPtr
                RTS

;
; CONV_INT24_STR DATA
;
Digits          FCB     0               ; number of digits (5)
Count           FCB     0               ; count for current digit
TempConv        FCB     0,0,0           ; value to convert
OutputOffset    FCB     0               ; digit being converted

OutputPtr       FDB     0               ; output string address

TableOffset     FCB     0               ; offset in conversion table
TablePtr        FDB     0

TableExp10      FCB     $0F,$42,$40     ; exp10(6) = 1000000
                FCB     $01,$86,$A0     ; exp10(5) =  100000
                FCB     $00,$27,$10     ; exp10(4) =   10000
                FCB     $00,$03,$E8     ; exp10(3) =    1000
                FCB     $00,$00,$64     ; exp10(2) =     100
                FCB     $00,$0,$0A      ; exp10(1) =      10

                END     Start
