;||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||;
;||||||||||||| Interrupción del ADC para cada conversión realizada ||||||||||||;
;||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||;
ADC_SAMPLE_STORE_TO_RAM_ISR:
    push    tmp ; En una interrupción hay que salvar el registro temporal
    in      tmp,SREG
    push    tmp ; También hay que salvar el status register

    in      tmp,ADCH   ; Muestra de 8 bits, ya que el ajuste es a izquierda
    st      Y+,tmp
    sbiw    tbl_jl,1   ; Decremento del contador de 16 bits
    brne    skip_stop_sampling ; Saltea si tbl_j no es cero
    ; Stop sampling
    clt ; El borrado del flag T indica que la conversión ha terminado
    ldi     tmp,ADC_DISABLE
    out     ADCSRA,tmp ; Se desactiva el ADC
skip_stop_sampling:
    pop     tmp
    out     SREG,tmp ; Se recupera el status register
    pop     tmp ; Se recupera el registro temporal

    reti


;|//////////////////////////////////////|\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\|;
;|/////////| Registro de 9 períodos en RAM a 37 muestras por período |\\\\\\\\|;
;|//////////////////////////////////////|\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\|;
;
; Al finalizar la tabla estará cargada en ADC_SAMPLES_RAM_TABLE con
; ADC_SAMPLES_TABLE_LEN muestras. Salva todos los registros que arruina.
;
ADC_SAMPLING_TO_RAM_FROM_IMPEDANCE_MEASURE_IN:
    ldi     tmp,ADC_AREF_LEFT_ADJUST_CONFIG | ADC_IMPEDANCE_MEASURE
    out     ADMUX,tmp

    ldi     tmp,ADC_ENABLE_AUTO_INT_PRESC
    out     ADCSRA,tmp

    ldi     YH,HIGH(ADC_SAMPLES_RAM_TABLE)
    ldi     YL,LOW(ADC_SAMPLES_RAM_TABLE)     ; Inicialización del puntero
    ldi     tbl_jh,HIGH(ADC_SAMPLES_TABLE_LEN)
    ldi     tbl_jl,LOW(ADC_SAMPLES_TABLE_LEN) ; Inicialización del contador
    set ; El flag T de SREG indicará que el muestreo está en curso

    sbi     ADCSRA,ADSC ; Inicio de la conversión

    ; Esperar hasta que todo esté muestreado en RAM 
wait_for_completion:
    brts    wait_for_completion

    ret
