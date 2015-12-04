CORREGIR_ELECTRODO:
    ; R21 -> R11 Tiene las decenas de la impedancia en kohms
    ; R20 -> R10 Tiene la unidad de la impedancia en kohms
    ; R23 -> R12 Tiene TMAX en cantidades de a 10 min
        
    clr     iter    ; iterador de la cantidad de minutos de corrección
    mov     R10,R20 ; copia hacia registros no utilizados por las rutinas
    mov     R11,R21 ; copia hacia registros no utilizados por las rutinas
    mov     R12,R23 ; copia hacia registros no utilizados por las rutinas

continuar_corrigiendo:
    ; Se mide para saber en qué rango corregir (queda en param)
    ; o si no es necesario hacerlo (medición en R1:R0)
    call    MEDIR

    ; Se copia la impedancia medida hacia R3:R2
    mov     R3,R1
    mov     R2,R0

    ; Verificación de la impedancia
    ldi     tmp,10
    mul     tmp,R11 ; R1:R0 <- Decenas de la impedancia en kohms * 10
    add     R0,R10  ; R1:R0 <- R1:R0 + Unidad de la impedancia en kohms
    clr     tmp
    adc     R1,tmp  ; Suma del carry a la parte alta (ya que tmp = 0)

    ; R1:R0 <- valor de impedancia deseada que se comparará con R3:R2 (medida)
    cp      R0,R2
    cpc     R1,R3
    brsh    final_correccion ; Si R1:R0 (deseada) >= R3:R2 (medida)

    call    PWM_CONTINUE_CORRECTION_START
    ldi     param,60
    call    DELAY_PARAM_SECONDS
    inc     iter

    ; Verificación de TMAX
    ldi     tmp,10
    mul     tmp,R12 ; R1:R0 <- TMAX en minutos, como es < 90, sólo interesa R0
    ; Aquí: R0 = TMAX; iter = TACTUAL (en minutos)
    cp      iter,R0
    brsh    final_correccion ; Si iter >= R0, se ha cumplido el tiempo máximo

    rjmp    continuar_corrigiendo

final_correccion:
    call    PWM_SINE_STOP
    call    DELAY_50ms
    call    MEDIR
    jmp     RESULTADOS_INIC
