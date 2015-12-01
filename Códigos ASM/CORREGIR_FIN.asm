CORREGIR_ELECTRODO:
			;R21 TIENE EL VALOR ALTO
			;R20 EL VALOR BAJO
			;R23 TIENE TMAX
			
        CLR iter

CONTINUAR_CORRIGIENDO:
		CALL MEDIR ; Esto sirve para saber en qué rango corregir (param)
		CALL PWM_CONTINUE_CORRECTION_START
        LDI PARAM,60
        CALL DELAY_PARAM_SECONDS
        INC iter
        CALL MEDIR

        ; Copiar la impedancia medida hacia R3:R2
        MOV R3,R1
        MOV R2,R0

		;VERIFICAR TMAX
        LDI TMP,10
        MUL TMP,R23 ; TMAX en minutos: R1:R0, como es < 90, sólo interesa R0
        ; Aquí: R0 = TMAX; iter = TACTUAL
        CP iter,R0
        BREQ FINAL_CORRECCION ; Se ha cumplido el tiempo máximo


        MUL TMP,R21 ; Decenas de la impedancia deciMegOhms
        CLR TMP
        ADD R0,R20  ; Unidad de la impedancia en deciMegOhms
        ADC R1,TMP  ; Suma del carry (ya que TMP = 0)

        ; R1:R0 es el valor de impedancia deseada que se comparará con R3:R2
        CP R2,R0
        CPC R3,R1
        BRLO CONTINUAR_CORRIGIENDO ; Salta si R3:R2 (medida) > R1:R0 (deseada)

FINAL_CORRECCION:
	CALL RESULTADOS_INIC
