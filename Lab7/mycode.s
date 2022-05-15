	GLOBAL	flashing
	AREA	mydata,DATA,READWRITE
		
SUMADR	DCD	0	;RESERVES 4BIT ADRESS

	AREA mycode,CODE,READONLY
	

flashing
user_code
PINSEL0	EQU	0xE0020000
IO0DIR	EQU	0x8
IO0PIN	EQU	0xE0028000
IO0SET	EQU	0x4
IO0CLR	EQU	0xC
LEDMASK EQU 0x0000FF00
	
	;TASK 1
num		EQU		0X9;sum will be from 1 to count
			LDR		R0, =num
			MOV		r1, #0x0
			MOV		r2, #0x0
			LDR		r4, =SUMADR

		
sum			ADD		r2, r2, #0x1 ;Increment R2 (R2++)
			ADD		r1, r1, r2 ;UPDATE R1 WITH R2 N+1(reccurance relation)
			STR 	r1, [r4],#4
			SUBS	r3, r0, #0x1;DECREMENT COUNTER AND SET FLAGS
			MOV		R0, r3	;update counter
			BNE		sum ;Loop if counter is NOT ZERO; EXIT if counter = 0(Z-flag)
		
;TASK 3 
	GLOBAL	user_code
	AREA	mycode, CODE, READONLY

		
char		EQU		0X6F 		; ascii for 'o'
			LDR		R0,=myString	;BASE ADRESS
			LDR		R2,=char
			MOV		R3,#0X0		;INITIALIZE COUNTER
			LDRB	R1,[R0]		;LOADING BYTES 
			CMP		R1,R2		;CHECKS IF THE CHAR IS A 'o'
			ADDEQ	R3,#0X1		;INCREMENTS COUNTER IF TRUE ^^^
		
charCount	LDRB	R1,[R0,#0X1]!	;SHIFTS ADRESS TO NEXT BYTE IN STRING. SAVES RESULT IN R0 MEMORY

			CMP		R1,R2	;CHECKS IF CHAR IS IN CURRENT BYTE
			ADDEQ	R3,#0X1	;INCREMENTS R3 IF TRUE
			CMP		R1,#0X0	;CHECKS IF REACHED ENDg   OF STRING 
			BNE		charCount
;task 4
PINSEL0	EQU	0xE0020000
IO0DIR	EQU	0x8
IO0PIN	EQU	0xE0028000
IO0SET	EQU	0x4
IO0CLR	EQU	0xC
LEDMASK EQU 0x0000FF00
	
CLOCK   EQU 12000000
DELAY1S	EQU (CLOCK/4)
	
		MOV r4, #0
		LDR r5, =PINSEL0
		STR r4, [r5]
		LDR r5, =IO0DIR
		LDR r6, [r5, #IO0DIR]
		LDR r4, =LEDMASK
		ORR r6,r6,r4
		STR r6, [r1,#IO0DIR]	
		
LOOP 	LDR r7, =5
	    SUBS r7,r7,#1
		MOV	r4, #LEDMASK
		STR r4, [r5,#IO0CLR]
		LDR r8, =DELAY1S
DELAY1  SUBS r8,r8,#1
		BNE DELAY1
		STR r4, [r5,#IO0SET]
		LDR r8, =DELAY1S
DELAY2  SUBS r8,r8,#1
		BNE DELAY2	
		BNE LOOP

myString	DCB	"Professor Flynn is the best professor in Northridge",0
			ALIGN

stop    B    stop    ;endless loop
    END
        