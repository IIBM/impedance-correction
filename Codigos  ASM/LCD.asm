.INCLUDE "M32DEF.INC"

			LDI R16,HIGH(RAMEND) ;Inicialización de la pila al final de la RAM
			OUT SPH,R16
			LDI R16,LOW(RAMEND)
			OUT SPL,R16
			
			LDI R19,1 ;Electrodo 1
			LDI ZL,0x60  ;Apunto a la direccion de memoria 60(esto es arbitrario), acá deberian estar los resultados
			LDI ZH,0x00
			
			.ORG 0
			JMP RESULTADOS
			.ORG 0X02  ;INTERRUPCION 0
			JMP SUBIR
			.ORG 0X04  ;INTERRUPCION 1
			JMP BAJAR
			
			LDI R16,0X00
			OUT DDRD,R16   ;En el puerto D estan las interrupciones 0 y 1
			LDI R16, (1<<ISC11)|(1<<ISC01)   ;Para que se habiliten por flanco ascendente
			OUT MCUCR, R16
	  
			LDI R16, (1<<INT1)|(1<<INT0)    ;Para que se habiliten las interrupciones 0 y 1
			OUT GICR,R16

			SEI ;Activa las interrupciones globales

			
RESULTADOS:
			
			CALL LCD_INIT ;Funcion para inicializar la LCD
			
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
			LDI R16,R19   ;El numero del electrodo(1,2,..16)
			CALL DATAWRT	
			LDI R16,$C0   ;Esto hay que revisarlo, es para bajar a la segunda linea del LCD
			CALL DATAWRT
			LD R16,Z   ;El resultado de la corrección
			CALL DATAWRT
			LDI R16,'M'
			CALL DATAWRT
			LDI R16,'Ω'  ;No se si lo va a leer
			CALL DATAWRT
			
			LDI R16,0X0F
			CALL CMNDWRT
			
FIN:RJMP FIN ;Se queda esperando las interrupciones
			
SUBIR:
		INC ZL ;Avanza el puntero
		INC R19
		CPI R19,17 ;Si se pasa del 16, vuelve al 1
		BREQ PRIMERO
		JMP RESULTADOS
PRIMERO:
		R19,1
		LDI ZL,0x60  
		LDI ZH,0x00
		JMP RESULTADOS
BAJAR: 
		DEC ZL ;Retrocede el puntero
		DEC R19
		CPI R19,0 ;Si se pasa del 1, vuelve al 16
		BREQ ULTIMO
		JMP RESULTADOS
ULTIMO:
		R19,16
		LDI ZL,0X75
		LDI ZH,0X00
		JMP RESULTADOS
			
;**************************************************************************************************************		
			
LCD_INIT:	
			LDI R21,0xFF	  
			OUT DDRB, R21
			OUT DDRC, R21
			CBI PORTC,5
			CALL DELAY_40ms
			LDI R16,0X38
			CALL CMNDWRT
			CALL CMNDWRT
			LDI R16,0X0E
			CALL CMNDWRT
			LDI R16,0X01
			CALL CMNDWRT
			CALL DELAY_1_6ms
			LDI R16,0X06
			CALL CMNDWRT
			RET
			

DELAY_40ms:
			LDI R17,25
		DR2:  
			CALL DELAY_1_6ms
			DEC R17
			BRNE DR2
			RET

DELAY_1_6ms:
			PUSH R17
			LDI R17,16
		DR1:  
		CALL DELAY_100us
		DEC R17
		BRNE DR1
		POP R17
		RET
		
			
DELAY_100us:
			PUSH R17
			LDI R17,13
		DR0:  CALL SDELAY
		DEC R17
		BRNE DR0
		POP R17
		RET


SDELAY:
			  NOP
			  NOP
			  RET

CMNDWRT:
			OUT PORTB,R16
			CBI PORTC,7
			CBI PORTC,6
			SBI PORTC,5
			CALL SDELAY
			CBI PORTC,5
			CALL DELAY_100us
			RET
	
DATAWRT:
			OUT PORTB,R16
			SBI PORTC,7
			CBI PORTC,6 
			SBI PORTC,5
			CALL SDELAY
			CBI PORTC,5
			CALL DELAY_100us
			RET
			
			