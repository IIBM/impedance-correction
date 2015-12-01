
		
RESULTADOS_INIC:			
			LDI R19,1 ;Electrodo 1
			LDI ZH,HIGH(BCD_TO_ASCII_CONVERT_RAM)
			LDI ZL,LOW(BCD_TO_ASCII_CONVERT_RAM)
			LDI R22,48	
		
			
RESULTADOS:
			
			CALL LCD_INIT ;Funcion para inicializar la LCD
			MOV R21,R19
			
			CPI R21,10
			BRLO RESULTADOS_1
			
			DIEZ:JMP DIEZ_I
			
RESULTADOS_1:
			
			ADD R19,R22
			LDI R16,'E'
			CALL DATAWRT
			LDI R16,'l'
			CALL DATAWRT
			LDI R16,'e'
			CALL DATAWRT
			LDI R16,'c'
			CALL DATAWRT
			LDI R16,'t'
			CALL DATAWRT
			LDI R16,'r'
			CALL DATAWRT
			LDI R16,'o'
			CALL DATAWRT
			LDI R16,'d'
			CALL DATAWRT
			LDI R16,'o'
			CALL DATAWRT
			LDI R16,' '
			CALL DATAWRT	  
			MOV R16,R19   ;El numero del electrodo(1,2,..16) 
			CALL DATAWRT	
			LDI R16,$C0   ;Esto hay que revisarlo, es para bajar a la segunda linea del LCD
			CALL CMNDWRT
			LD R16,Z+   ;El resultado de la corrección
			CALL DATAWRT
			LD R16,Z+   ;El resultado de la corrección
			CALL DATAWRT
			LD R16,Z+   ;El resultado de la corrección
			CALL DATAWRT
			LD R16,Z+   ;El resultado de la corrección
			CALL DATAWRT
			LDI R16,'.'
			CALL DATAWRT
			LD R16,Z   ;El resultado de la corrección
			CALL DATAWRT
			LDI R16,'M'
			CALL DATAWRT
			LDI R16,'O'  
		    CALL DATAWRT
		    LDI R16,'h'  
		    CALL DATAWRT
		    LDI R16,'m'  
		    CALL DATAWRT
			SUB R19,R22
			
			LDI R16,0X0F
			CALL CMNDWRT
			
			CALL DELAY_50ms
		
			
BOTONES_4:		
		IN R17,PINA
		BST R17,3  ;Pin 3 del puerto A (AUMENTAR)
		BRTC SUBIR
		BST R17,4  ;Pin 4 del puerto A (REDUCIR)
		BRTC BAJAR
JMP BOTONES_4
			
SUBIR:
        ADIW ZL,1 ; Avanza el puntero
		INC R19
		CPI R19,17 ;Si se pasa del 16, vuelve al 1
		BREQ PRIMERO
		JMP RESULTADOS
PRIMERO:
		LDI R19,16
        SBIW ZL,1
		JMP BOTONES_4
BAJAR: 
        SBIW ZL,5 ; Retrocede el puntero
		DEC R19
		CPI R19,0 ;Si se pasa del 1, vuelve al 16
		BREQ ULTIMO
		JMP RESULTADOS
ULTIMO:
		LDI R19,1
        LDI ZH,HIGH(BCD_TO_ASCII_CONVERT_RAM)
        LDI ZL,LOW(BCD_TO_ASCII_CONVERT_RAM)
		JMP BOTONES_4
		
		
DIEZ_I:     
			SUBI R21,10
			ADD R21,R22

			LDI R16,'E'
			CALL DATAWRT
			LDI R16,'l'
			CALL DATAWRT
			LDI R16,'e'
			CALL DATAWRT
			LDI R16,'c'
			CALL DATAWRT
			LDI R16,'t'
			CALL DATAWRT
			LDI R16,'r'
			CALL DATAWRT
			LDI R16,'o'
			CALL DATAWRT
			LDI R16,'d'
			CALL DATAWRT
			LDI R16,'o'
			CALL DATAWRT
			LDI R16,' '
			CALL DATAWRT	
			LDI R16,0x31
			CALL DATAWRT
			MOV R16,R21   ;El numero del electrodo(1,2,..16) 
			CALL DATAWRT	
			LDI R16,$C0   ;Esto hay que revisarlo, es para bajar a la segunda linea del LCD
			CALL CMNDWRT
			LD R16,Z+   ;El resultado de la corrección
			CALL DATAWRT
			LD R16,Z+   ;El resultado de la corrección
			CALL DATAWRT
			LD R16,Z+   ;El resultado de la corrección
			CALL DATAWRT
			LD R16,Z+   ;El resultado de la corrección
			CALL DATAWRT
			LDI R16,'.'
			CALL DATAWRT
			LD R16,Z   ;El resultado de la corrección
			CALL DATAWRT
			LDI R16,'M'
			CALL DATAWRT
			LDI R16,'O'  
		    CALL DATAWRT
		    LDI R16,'h'  
		    CALL DATAWRT
		    LDI R16,'m'  
		    CALL DATAWRT
			
			SUB R21,R22  ;VUELVO A LA VARIABLE
			

			LDI R16,0X0F
			CALL CMNDWRT
			
			CALL DELAY_50ms
			
			
			JMP BOTONES_4

