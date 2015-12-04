INT2_ESC_BUTTON_ISR:
        POP R16
        POP R16
        SEI     ; Deshace los cambios de la llamada a la interrupción y continúa hacia MENU

MENU:
		LDI param,MEAS_RANGE_4
		CALL PWM_SINE_STOP    ; Se inicializa el PWM de senoidal
		CALL PWM_OFFSET_START ; Se inicializa la referencia del OpAmp

        ; Se limpia la RAM de pantalla LCD
        LDI R16,80
        LDI ZH,HIGH(BCD_TO_ASCII_CONVERT_RAM)
        LDI ZL,LOW(BCD_TO_ASCII_CONVERT_RAM)
        LDI R17,'*'
LCD_RAM_INIT:
        ST Z+,R17
        DEC R16
        BRNE LCD_RAM_INIT
		CALL LCD_INIT
		
MED:	
		LDI R16, 0X01
		CALL CMNDWRT	  ;Pone el cursor al principio de la 1ra línea 
		CALL DELAY_1_6ms
		
		
		LDI R16,'M'
		CALL DATAWRT
		LDI R16,'E'
		CALL DATAWRT
		LDI R16,'D'		
		CALL DATAWRT
		LDI R16,'I'		
		CALL DATAWRT
		LDI R16,'R'		
		CALL DATAWRT
		LDI R16,' '		
		CALL DATAWRT
		LDI R16,' '		
		CALL DATAWRT
		LDI R16,' '		
		CALL DATAWRT
		LDI R16,'O'		
		CALL DATAWRT
		LDI R16,'K'		
		CALL DATAWRT


		LDI R16,$C0   
		CALL CMNDWRT
		
		LDI R16,60  
		CALL DATAWRT
		LDI R16,62   
		CALL DATAWRT
			
BOTONES:

		IN R17, PINA
		BST R17,3 
		BRTC CALIBRAR_1
		BST R17,4 
		BRTC CORREGIR_JMP
		BST R17,5  
		BRTC MEDIR_JMP
						
JMP BOTONES

MEDIR_JMP:
		JMP MEDIR_MENU

CORREGIR_JMP:
		JMP CORREGIR_1

CALIBRAR_1:
		LDI R16, 0X01
		CALL CMNDWRT	  ;Pone el cursor al principio de la 1ra línea 
		CALL DELAY_1_6ms
		
		
		LDI R16,'C'
		CALL DATAWRT
		LDI R16,'A'
		CALL DATAWRT
		LDI R16,'L'		
		CALL DATAWRT
		LDI R16,'I'		
		CALL DATAWRT
		LDI R16,'B'		
		CALL DATAWRT
		LDI R16,'R'		
		CALL DATAWRT
		LDI R16,'A'		
		CALL DATAWRT
		LDI R16,'R'		
		CALL DATAWRT
		LDI R16,' '		
		CALL DATAWRT
		LDI R16,' '		
		CALL DATAWRT
		LDI R16,' '		
		CALL DATAWRT
		LDI R16,'O'		
		CALL DATAWRT
		LDI R16,'K'		
		CALL DATAWRT


		LDI R16,$C0   
		CALL CMNDWRT
		
		LDI R16,60  
		CALL DATAWRT
		LDI R16,62   
		CALL DATAWRT

		CALL DELAY_50ms
BOT:		
		IN R17, PINA
		BST R17,3 
		BRTC CORREGIR_1
		BST R17,4 
		BRTC MED_JMP
		BST R17,5  
		BRTC CALIBRAR_JMP
JMP BOT

CALIBRAR_JMP:
		JMP CALIBRAR

MED_JMP:
		JMP MED

		
MEDIR_MENU:
		CALL MEDIR
		JMP RESULTADOS_INIC
		RET

CALIBRAR:
	RJMP CALIBRAR
		
CORREGIR_1:
		LDI R16, 0X01
		CALL CMNDWRT	  ;Pone el cursor al principio de la 1ra línea 
		CALL DELAY_1_6ms
		
		
		LDI R16,'C'
		CALL DATAWRT
		LDI R16,'O'
		CALL DATAWRT
		LDI R16,'R'		
		CALL DATAWRT
		LDI R16,'R'		
		CALL DATAWRT
		LDI R16,'E'		
		CALL DATAWRT
		LDI R16,'G'		
		CALL DATAWRT
		LDI R16,'I'		
		CALL DATAWRT
		LDI R16,'R'		
		CALL DATAWRT
		LDI R16,' '		
		CALL DATAWRT
		LDI R16,' '		
		CALL DATAWRT
		LDI R16,' '		
		CALL DATAWRT
		LDI R16,'O'		
		CALL DATAWRT
		LDI R16,'K'		
		CALL DATAWRT


		LDI R16,$C0   
		CALL CMNDWRT
		
		LDI R16,60  
		CALL DATAWRT
		LDI R16,62   
		CALL DATAWRT

		CALL DELAY_50ms
BOT2:		
		IN R17, PINA
		BST R17,3 
		BRTC MED_JMP1
		BST R17,4 
		BRTC CALIBRAR_JMP1
		BST R17,5  
		BRTC CORREGIR
JMP BOT2		

MED_JMP1:
	JMP MED

CALIBRAR_JMP1:
	JMP CALIBRAR_1

CORREGIR:
		LDI R22, 0
		LDI R16, 0X01
		CALL CMNDWRT	  
		CALL DELAY_1_6ms
		
		LDI R16,'I'
		CALL DATAWRT
		LDI R16,'M'
		CALL DATAWRT
		LDI R16,'P'
		CALL DATAWRT
		LDI R16,'E'
		CALL DATAWRT
		LDI R16,'D'
		CALL DATAWRT
		LDI R16,'A'
		CALL DATAWRT
		LDI R16,'N'
		CALL DATAWRT
		LDI R16,'C'
		CALL DATAWRT
		LDI R16,'I'
		CALL DATAWRT
		LDI R16,'A'
		CALL DATAWRT
		
		LDI R16,$C0   
		CALL CMNDWRT
		
		LDI R16,0X30
		CALL DATAWRT
		LDI R16,0X30
		CALL DATAWRT	
		LDI R16,'k'
		CALL DATAWRT	  
		LDI R16,'O'  
		CALL DATAWRT
		LDI R16,'h'  
		CALL DATAWRT
		LDI R16,'m'  
		CALL DATAWRT

	CALL DELAY_50ms
		
		LDI R20,0 
		LDI R21,0 

BOTONES_2:		
		IN R17 ,PINA
		BST R17,3  ;Pin 3 del puerto A (AUMENTAR)
		BRTC AUMENTAR
		BST R17,4  ;Pin 4 del puerto A (REDUCIR)
		BRTC REDUCIR_OK
		BST R17,5  ;PIN 5 DEL PUERTO A (OK)
		BRTC TMAX_OK
JMP BOTONES_2

REDUCIR_OK:JMP REDUCIR ;CON EL BRANCH NO ALCANZA PARA SALTAR
TMAX_OK:JMP TMAX
	
AUMENTAR:
		INC R20
		CPI R20,10
		BRNE AUMENTAR_A
		INC R21
		LDI R20,0
		

AUMENTAR_A:	

		CPI  R21,8     ;DEJA HASTA 7,9 MOHM
		BRSH BOTONES_2
		
		LDI R16, 0X01
		CALL CMNDWRT	  
		CALL DELAY_1_6ms
		
		LDI R16,'I'
		CALL DATAWRT
		LDI R16,'M'
		CALL DATAWRT
		LDI R16,'P'
		CALL DATAWRT
		LDI R16,'E'
		CALL DATAWRT
		LDI R16,'D'
		CALL DATAWRT
		LDI R16,'A'
		CALL DATAWRT
		LDI R16,'N'
		CALL DATAWRT
		LDI R16,'C'
		CALL DATAWRT
		LDI R16,'I'
		CALL DATAWRT
		LDI R16,'A'
		CALL DATAWRT
		
		LDI R16,$C0   
		CALL CMNDWRT
		
		LDI R22,48    ;PARA PASAR A ASCII
		ADD R21,R22
		ADD R20,R22
		
		MOV R16,R21   
		CALL DATAWRT
		MOV R16,R20   
		CALL DATAWRT	
		LDI R16,'k'
		CALL DATAWRT	  
		LDI R16,'O'  
		CALL DATAWRT
		LDI R16,'h'  
		CALL DATAWRT
		LDI R16,'m'  
		CALL DATAWRT
		
		SUB R21,R22  ;VUELVO A LA VARIABLE
		SUB R20,R22
		
		CALL DELAY_50ms
		CALL DELAY_50ms

		JMP BOTONES_2
		
REDUCIR:
		CPI R20,0
		BREQ REDUCIR_B
		DEC R20
		JMP REDUCIR_A
REDUCIR_B:
		CPI R21,0
		BREQ SALIDA
		DEC R21
		LDI R20,9
		JMP REDUCIR_A
SALIDA:
		JMP BOTONES_2
		
		

REDUCIR_A:	
			
		LDI R16, 0X01
		CALL CMNDWRT	  
		CALL DELAY_1_6ms	
		
		LDI R16,'I'
		CALL DATAWRT
		LDI R16,'M'
		CALL DATAWRT
		LDI R16,'P'
		CALL DATAWRT
		LDI R16,'E'
		CALL DATAWRT
		LDI R16,'D'
		CALL DATAWRT
		LDI R16,'A'
		CALL DATAWRT
		LDI R16,'N'
		CALL DATAWRT
		LDI R16,'C'
		CALL DATAWRT
		LDI R16,'I'
		CALL DATAWRT
		LDI R16,'A'
		CALL DATAWRT
		
		LDI R16,$C0   
		CALL CMNDWRT
		
		LDI R22,48    ;PARA PASAR A ASCII
		ADD R21,R22
		ADD R20,R22
		
		MOV R16,R21   ;CAMBIAR
		CALL DATAWRT
		MOV R16,R20   ;CAMBIAR
		CALL DATAWRT	
		LDI R16,'k'
		CALL DATAWRT	  
		LDI R16,'O'  
		CALL DATAWRT
		LDI R16,'h'  
		CALL DATAWRT
		LDI R16,'m'  
		CALL DATAWRT
		
		SUB R21,R22  ;VUELVO A LA VARIABLE
		SUB R20,R22
		
		CALL DELAY_50ms
		CALL DELAY_50ms

		JMP BOTONES_2		

TMAX:
		LDI R16, 0X01
		CALL CMNDWRT	 
		CALL DELAY_1_6ms
		
		LDI R16,'T'
		CALL DATAWRT
		LDI R16,'M'
		CALL DATAWRT
		LDI R16,'A'
		CALL DATAWRT
		LDI R16,'X'
		CALL DATAWRT
		
		LDI R16,$C0   
		CALL CMNDWRT
		
		LDI R16,0X30  
		CALL DATAWRT  
		LDI R16,0X30
		CALL DATAWRT	
		
		LDI R16,'M'
		CALL DATAWRT
		LDI R16,'I'
		CALL DATAWRT
		LDI R16,'N'
		CALL DATAWRT
		
		LDI R23,0
		LDI R22,48 

		CALL DELAY_50ms
		
		
	BOTONES_3:		
		IN R17 ,PINA
		BST R17,3  ;Pin 3 del puerto A (AUMENTAR)
		BRTC AUMENTAR_T
		BST R17,4  ;Pin 4 del puerto A (REDUCIR)
		BRTC REDUCIR_T
		BST R17,5  ;PIN 5 DEL PUERTO A (OK)
		BRTC FIN
	JMP BOTONES_3
	FIN:
		LDI R16, 0X01
		CALL CMNDWRT	 
		CALL DELAY_1_6ms
		
		LDI R16,'E'
		CALL DATAWRT
		LDI R16,'S'
		CALL DATAWRT
		LDI R16,'P'
		CALL DATAWRT
		LDI R16,'E'
		CALL DATAWRT
		LDI R16,'R'
		CALL DATAWRT
		LDI R16,'E'
		CALL DATAWRT
		LDI R16,'.'
		CALL DATAWRT
		LDI R16,'.'
		CALL DATAWRT
		LDI R16,'.'
		CALL DATAWRT
        JMP CORREGIR_ELECTRODO
		
	REDUCIR_T:
	
		CPI R23,0
		BRNE REDUCIR_TP
		JMP BOTONES_3


	AUMENTAR_T:
		CPI R23,9
		BRSH BOTONES_3
		INC R23
		
	
	AUMENTAR_TP:
	
		LDI R16, 0X01
		CALL CMNDWRT	 
		CALL DELAY_1_6ms
		
		LDI R16,'T'
		CALL DATAWRT
		LDI R16,'M'
		CALL DATAWRT
		LDI R16,'A'
		CALL DATAWRT
		LDI R16,'X'
		CALL DATAWRT
		
		LDI R16,$C0   
		CALL CMNDWRT
		
		ADD R23,R22
		
		MOV R16,R23 
		CALL DATAWRT  
		LDI R16,0X30
		CALL DATAWRT	
		
		LDI R16,'M'
		CALL DATAWRT
		LDI R16,'I'
		CALL DATAWRT
		LDI R16,'N'
		CALL DATAWRT
		
		SUB R23,R22
		
		CALL DELAY_50ms	
		
	JMP BOTONES_3

		
	REDUCIR_TP:
		
		DEC R23
		LDI R16, 0X01
		CALL CMNDWRT	 
		CALL DELAY_1_6ms
		
		LDI R16,'T'
		CALL DATAWRT
		LDI R16,'M'
		CALL DATAWRT
		LDI R16,'A'
		CALL DATAWRT
		LDI R16,'X'
		CALL DATAWRT
		
		LDI R16,$C0   
		CALL CMNDWRT
		
		ADD R23,R22
		
		MOV R16,R23 
		CALL DATAWRT
		LDI R16,'0'
		CALL DATAWRT	
		
		LDI R16,'M'
		CALL DATAWRT
		LDI R16,'I'
		CALL DATAWRT
		LDI R16,'N'
		CALL DATAWRT
		
		SUB R23,R22
		
		CALL DELAY_50ms	
		
	JMP BOTONES_3
		
		

		
		FIN2:RJMP FIN2
	
	;***************************************************************************************************************************
		
		LCD_INIT:	
			CBI PORTA,2
			CALL DELAY_50ms
			LDI R16,0X38
			CALL CMNDWRT
			LDI R16,0X0E
			CALL CMNDWRT
			LDI R16,0X01
			CALL CMNDWRT
			CALL DELAY_50ms
			LDI R16,0X06
			CALL CMNDWRT
			RET
			
		;**********************************************************************************************************************************	
		
		DELAY_40ms:
			LDI R17,25
		DR2:  
			CALL DELAY_1_6ms
			DEC R17
			BRNE DR2
			RET

		;*********************************************************************************************************************************
		DELAY_1_6ms:
			PUSH R17
			LDI R17,16
		DR1:  
		CALL DELAY_100us
		DEC R17
		BRNE DR1
		POP R17
		RET

		;********************************************************************************************************************************
		DELAY_100us:
			PUSH R17
			LDI R17,13
		DR0:  CALL SDELAY
		DEC R17
		BRNE DR0
		POP R17
		RET

		;**************************************************************************************************************************

		SDELAY:
			  NOP
			  NOP
			  RET

		;**************************************************************************************************************************
		CMNDWRT:
			OUT PORTC,R16
			CBI PORTA,0
			CBI PORTA,1
			SBI PORTA,2
			CALL DELAY_100us
			CBI PORTA,2
			CALL DELAY_50ms
			RET
		;*************************************************************************************************************************
		DATAWRT:
			OUT PORTC,R16
			SBI PORTA,0
			CBI PORTA,1 
			SBI PORTA,2
			CALL DELAY_100us
			CBI PORTA,2
			CALL DELAY_50ms
			RET
