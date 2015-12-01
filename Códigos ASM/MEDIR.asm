MEDIR:
		LDI param,MEAS_RANGE_60
		
MEDIR_GRAL:		
        CALL PWM_SINE_START
		CALL DELAY_50ms
		CALL ADC_SAMPLING_TO_RAM_FROM_IMPEDANCE_MEASURE_IN
		CALL PWM_SINE_STOP
		CALL GET_THE_PEAK_VALUE_IN_R2_FROM_ADC_RAM_TABLE
		CALL GET_DECIMEG_IMPEDANCE_FROM_PARAM_RANGE_R2_PEAK_VALUE_IN_R1_R0
		
        flash_point_Z_plus_param MEAS_RANGE_FLASH_SIN_MUX2_VALUES
        LPM     R2,Z       ; Se carga en R2 el piso del rango actual (param)
        
        CLR     tmp        ; tmp = 0
        CP      R0,R2      ; Comparación, parte baja
        CPC     R1,tmp     ; Comparación, parte alta
        BRSH    meas_ready ; Si R1:R0 (medición actual) >= R2 (piso de rango), listo
        DEC     param      ; Si no, paso a un rango más bajo
        BRNE    MEDIR_GRAL ; Repetir medición

meas_ready:
		CALL BCD
        RET
