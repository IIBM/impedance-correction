.INCLUDE "M32DEF.INC"

;HAY QUE CAMBIAR LOS PUERTOS DE A PARA LA LCD 
		
			
			LDI R19,1 ;Electrodo 1
			LDI ZL,0x60  ;Apunto a la direccion de memoria 60(esto es arbitrario), acá deberian estar los resultados
			LDI ZH,0x00
					
		
			
RESULTADOS:
			
			CALL LCD_INIT ;Funcion para inicializar la LCD
			MOV R21,R19
			
			CPI R21,10
			BRLO RESULTADOS_1
			
			DIEZ:JMP DIEZ_I
			
RESULTADOS_1:
			
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
	
			
			LDI R16,0X0F
			CALL CMNDWRT
			
			CALL DELAY_40ms
			CALL DELAY_40ms
			CALL DELAY_40ms
			
BOTONES_4:		
		IN R17 ,PINA
		BST R17,4  ;Pin 3 del puerto A (AUMENTAR)
		BRTS SUBIR
		BST R17,5  ;Pin 4 del puerto A (REDUCIR)
		BRTS BAJAR
JMP BOTONES_4
			
SUBIR:
		INC ZL ;Avanza el puntero
		INC R19
		CPI R19,17 ;Si se pasa del 16, vuelve al 1
		BREQ PRIMERO
		JMP RESULTADOS
PRIMERO:
		LDI R19,16
		DEC ZL
		JMP BOTONES_4
BAJAR: 
		SUBI ZL,5 ;Retrocede el puntero
		DEC R19
		CPI R19,0 ;Si se pasa del 1, vuelve al 16
		BREQ ULTIMO
		JMP RESULTADOS
ULTIMO:
		LDI R19,1
		LDI ZL,0x60  ;Apunto a la direccion de memoria 60(esto es arbitrario), acá deberian estar los resultados
		LDI ZH,0x00
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
			
			CALL DELAY_40ms
			CALL DELAY_40ms
			CALL DELAY_40ms
			
			JMP BOTONES_4

