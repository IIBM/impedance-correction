	.INCLUDE "M32DEF.INC"
	
	BCD:
			
			LDI ZL,0x60
			LDI ZH,0x00
			.def rBin1H =r1  ;REGISTROS MULTIPLICACION
			.def rBin1L =r0
			.def rBin2H =r19
			.def rBin2L =r20
			.def rmp =r18
	       
			
			CALL Bin2ToAsc5
			
			RET
	
	
	Bin2ToAsc5:
	rcall Bin2ToBcd5 
	ldi rmp,4 
	mov rBin2L,rmp
Bin2ToAsc5a:
	ld rmp,z 
	tst rmp 
	brne Bin2ToAsc5b 
	ldi rmp,' ' 
	st z+,rmp 
	dec rBin2L 
	brne Bin2ToAsc5a 
	ld rmp,z 
Bin2ToAsc5b:
	inc rBin2L 
Bin2ToAsc5c:
	subi rmp,-'0' 
	st z+,rmp 
	ld rmp,z 
	dec rBin2L ;
	brne Bin2ToAsc5c 
	sbiw ZL,5 ;DIRECCIÓN FINAL
	ret 


		
	Bin2ToBcd5:
	push rBin1H 
	push rBin1L
	ldi rmp,HIGH(10000) 
	mov rBin2H,rmp
	ldi rmp,LOW(10000)
	mov rBin2L,rmp
	rcall Bin2ToDigit 
	ldi rmp,HIGH(1000) 
	mov rBin2H,rmp
	ldi rmp,LOW(1000)
	mov rBin2L,rmp
	rcall Bin2ToDigit 
	ldi rmp,HIGH(100) 
	mov rBin2H,rmp
	ldi rmp,LOW(100)
	mov rBin2L,rmp
	rcall Bin2ToDigit 
	ldi rmp,HIGH(10) 
	mov rBin2H,rmp
	ldi rmp,LOW(10)
	mov rBin2L,rmp
	rcall Bin2ToDigit 
	st z,rBin1L 
	sbiw ZL,4 
	pop rBin1L 
	pop rBin1H
	ret 


Bin2ToDigit:
	clr rmp 
Bin2ToDigita:
	cp rBin1H,rBin2H 
	brcs Bin2ToDigitc 
	brne Bin2ToDigitb 
	cp rBin1L,rBin2L 
	brcs Bin2ToDigitc 
Bin2ToDigitb:
	sub rBin1L,rBin2L 
	sbc rBin1H,rBin2H 
	inc rmp 
	rjmp Bin2ToDigita 
Bin2ToDigitc:
	st z+,rmp 
	ret 
	
	
	