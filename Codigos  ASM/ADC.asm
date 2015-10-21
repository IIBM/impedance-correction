.INCLUDE "M32DEF.INC"

;*****Conversión ADC*******************************************************************************************************
		CONV_ADC:
		  LDI R16,0x87 ;Habilitación del ADC y selección del clock del ADC como clk/128
		  OUT ADCSRA,R16
		  LDI R16,0x40 ;Elección de Vref=VCC, justificación derecha de los resultados y pin de entrada simple ADC0(PIN 40)
		  OUT ADMUX,R16
		  SBI ADCSRA,ADSC ;Inicio de la conversión
		FADC: SBIS ADCSRA,ADIF ;Revisión de fin de la conversión
		  RJMP FADC
		  CBI ADCSRA,ADIF ;Limpia el bit de aviso de fin de conversión
		  IN R0,ADCL ;Copio los resultados a registros generales
		  IN R1,ADCH
		  MOV R16,R0
		  MOV R17,R1
		  RET
		 