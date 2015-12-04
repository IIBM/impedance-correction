MEDIR:
    ldi     param,MEAS_RANGE_4
    call    PWM_OFFSET_START
        
medir_gral:    
    call    PWM_SINE_START
    call    DELAY_50ms
    call    ADC_SAMPLING_TO_RAM_FROM_IMPEDANCE_MEASURE_IN
    call    PWM_SINE_STOP
    call    GET_THE_PEAK_VALUE_IN_R2_FROM_ADC_RAM_TABLE
    call    GET_DECIMEG_IMPEDANCE_FROM_PARAM_RANGE_R2_PEAK_VALUE_IN_R1_R0
    
    ldi     ZH,HIGH(MEAS_RANGE_FLASH_FLOOR_VALUES<<1)
    ldi     ZL,LOW(MEAS_RANGE_FLASH_FLOOR_VALUES<<1)

    mov     R2,param
    lsl     R2         ; R2 = param * 2
    clr     tmp
    add     ZL,R2      ; Z = Z + param * 2
    adc     ZH,tmp     ; Actualización de la parte alta con el carry (tmp = 0)

    lpm     R2,Z+ ; Lectura del parámetro P desde flash, little-endian (L)
    lpm     R3,Z  ; Lectura del parámetro P desde flash, little-endian (H) 
    
    cp      R0,R2       ; Comparación, parte baja
    cpc     R1,R3       ; Comparación, parte alta
    brsh    medir_listo ; Si R1:R0 (medición actual) >= R3:R2 (piso de rango)
    dec     param       ; Si no, paso a un rango más bajo
    brne    medir_gral  ; Repetir medición

medir_listo:
    call    BCD
    ret
