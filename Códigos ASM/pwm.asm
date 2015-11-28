;||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||;
;||||||||| Interrupción de actualización del ciclo de trabajo del PWM |||||||||;
;||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||;
PWM_DUTY_CYCLE_UPDATE_ISR:
    push    tmp ; En una interrupción hay que salvar el registro temporal
    in      tmp,SREG
    push    tmp ; También hay que salvar el status register

    ld      tmp,X+    ; Próximo valor del ciclo de trabajo desde RAM
    out     OCR0,tmp  ; Valor actualizado de ciclo de trabajo
    dec     tbl_i     ; Decremento del iterador de la tabla en RAM
    brne    skip_go_beginning ; Saltea si tbl_i no es cero
    ; Go beginning
    rcall   SINE_RAM_TABLE_GO_BEGINNING
skip_go_beginning:
    pop     tmp
    out     SREG,tmp ; Se recupera el status register
    pop     tmp ; Se recupera el registro temporal
    reti


;|//////////////////////////////////////|\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\|;
;|///| Apuntado de la tabla del seno en RAM e inicialización del contador |\\\|;
;|//////////////////////////////////////|\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\|;
;
; NOTA: tbl_i (R18) y X (R27:R26) siempre en uso.
;
SINE_RAM_TABLE_GO_BEGINNING:
    ldi     XH,HIGH(PWM_SINE_RAM_TABLE)
    ldi     XL,LOW(PWM_SINE_RAM_TABLE) ; Tabla de onda escalada en RAM
    ldi     tbl_i,PWM_SINE_TABLE_LEN   ; Iterador de la tabla en RAM
    ret


;|//////////////////////////////////////|\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\|;
;|///////////////////////| Carga de la tabla del seno |\\\\\\\\\\\\\\\\\\\\\\\|;
;|//////////////////////////////////////|\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\|;
;
; param (R17) <- escalado de amplitud x 128, ejemplo: 25% = 32/128 => param = 32
; Al finalizar la tabla estará cargada en PWM_SINE_RAM_TABLE, escalada por
; param/128 y con un valor medio de PWM_SINE_MEDIAN. Salva todos los registros
; que arruina.
;
LOAD_SINE_RAM_TABLE_SCALED:
    push    R0
    push    R1
    push    tbl_i
    push    ZH
    push    ZL
    push    XH
    push    XL ; Registros salvados en el stack

    ldi     ZH,HIGH(PWM_SINE_FLASH_TABLE<<1)
    ldi     ZL,LOW(PWM_SINE_FLASH_TABLE<<1) ; Inicialización de puntero en flash
    rcall   SINE_RAM_TABLE_GO_BEGINNING ; Carga el puntero X y el contador tbl_i

loop_sine_table:
    lpm     tmp,Z+    ; Lectura desde flash, del sample original
    mulsu   tmp,param ; Sample escalado y multiplicado x 128 en R1:R0
    rol     R0 ;> División por 128: se multiplica por 2 el entero de 16 bits
    rol     R1 ;> con shifts y luego se divide por 256 quedándose con R1 (MSB)
    ldi     tmp,PWM_SINE_MEDIAN
    add     R1,tmp    ; En R1 queda el sample más la media
    st      X+,R1     ; Carga en RAM del sample final
    dec     tbl_i     ; Decremento del contador
    brne    loop_sine_table

    pop     XL
    pop     XH
    pop     ZL
    pop     ZH
    pop     tbl_i
    pop     R1
    pop     R0 ; Registros recuperados del stack
    ret


;------------------------------------------------------------------------------;
;---------------- Macros que utilizarán las siguientes rutinas ----------------;
;------------------------------------------------------------------------------;

; Carga en el puntero Z la dirección de flash recibida en como argumento + param
.macro flash_point_Z_plus_param
    ldi     ZH,HIGH(@0<<1)
    ldi     ZL,LOW(@0<<1) ; Puntero en flash
    clr     tmp      ; Se borra el registro temporario
    add     ZL,param ; Se desplaza en la tabla según el parámetro de entrada
    adc     ZH,tmp   ; Se suma el acarreo a la parte alta (tmp = 0)
.endmacro

; Escribe el valor del MUX2 según R0, sin chequear su contenido
.macro set_MUX2_with_R0_value
    cli     ; Se desactivan las interrupciones para hacer el cambio
    in      tmp,PORTB                   ; Lectura desde el puerto B
    cbr     tmp,(1<<PORTB0)|(1<<PORTB1) ; Limpieza de los bit del MUX2
    or      tmp,R0                      ; Se graban los bit del MUX2 con R0
    out     PORTB,tmp                   ; Escritura hacia el puerto B
    sei     ; Se vuelven a activar las interrupciones
.endmacro


;|//////////////////////////////////////|\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\|;
;|/////////| Encender la senoidal, para el rango de medición deseado |\\\\\\\\|;
;|//////////////////////////////////////|\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\|;
;
; param (R17) <- rango, 4 opciones: MEAS_RANGE_X con X en {2, 8, 20, 60}
; Encenderá el PWM de la senoidal para un rango de medición determinado,
; especificado en el parámetro de entrada, por medio de un valor "enumerativo"
; MEAS_RANGE_X, no hace chequeos de borde, se asume que se recibe un valor
; correcto. Salva todos los registros que arruina.
;
PWM_SINE_START:
    push    R0
    push    param
    push    ZH
    push    ZL ; Registros salvados en el stack

    ; Selección del multiplexor MUX2
    flash_point_Z_plus_param MEAS_RANGE_FLASH_SIN_MUX2_VALUES
    lpm     R0,Z
    set_MUX2_with_R0_value

    ; Creación de tabla en RAM
    flash_point_Z_plus_param MEAS_RANGE_FLASH_SINAMPS
    lpm     param,Z  ; Valor correspondiente de amplitud para la rutina
    rcall   LOAD_SINE_RAM_TABLE_SCALED

    ; Inicialización del puntero X y el contador tbl_i, no se pueden usar más!
    rcall   SINE_RAM_TABLE_GO_BEGINNING

    ; Configuración del Timer0 como PWM
    ldi     tmp,PWM_FAST_PWM_CONFIG
    out     TCCR0,tmp   ; Habilita el PWM en modo rápido
    in      tmp,TIMSK
    sbr     tmp,PWM_OV_INTERRUPT_MASK
    out     TIMSK,tmp   ; Habilita la interrupción de overflow Timer0

    pop     ZL
    pop     ZH
    pop     param
    pop     R0 ; Registros recuperados del stack
    ret


;|//////////////////////////////////////|\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\|;
;|////////////| Apagar la onda de salida (dejar PWM al 50 % fijo) |\\\\\\\\\\\|;
;|//////////////////////////////////////|\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\|;
;
; Apaga la onda del PWM, es decir que deja lo deja en su valor medio de forma
; constante (50 % de duty cycle). Salva todos los registros que arruina.
;
PWM_SINE_STOP:
    push    R0 ; Registros salvados en el stack

    ; Se pone el MUX2 en x30nA para minimizar errores de offset
    ldi     tmp,MUX2_x30nA
    mov     R0,tmp
    set_MUX2_with_R0_value

    ; Configuración del Timer0 como PWM
    ldi     tmp,PWM_FAST_PWM_CONFIG
    out     TCCR0,tmp   ; Habilita el PWM en modo rápido
    in      tmp,TIMSK
    cbr     tmp,PWM_OV_INTERRUPT_MASK
    out     TIMSK,tmp   ; Deshabilita la interrupción de overflow Timer0

    ldi     tmp,PWM_SINE_MEDIAN
    out     OCR0,tmp    ; Pone el valor medio en la salida

    pop     R0 ; Registros recuperados del stack
    ret


;|//////////////////////////////////////|\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\|;
;|//| Encender la continua de corrección, para el rango de medición deseado |\|;
;|//////////////////////////////////////|\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\|;
;
; param (R17) <- rango, 4 opciones: MEAS_RANGE_X con X en {2, 8, 20, 60}
; Encenderá el PWM en el modo de corrección, es decir, señales continuas. Según
; el rango especificado en el parámetro de entrada, por medio de un valor
; "enumerativo" MEAS_RANGE_X, no hace chequeos de borde, se asume que se recibe
; un valor correcto. Salva todos los registros que arruina.
;
PWM_CONTINUE_CORRECTION_START:
    push    R0
    push    ZH
    push    ZL ; Registros salvados en el stack

    ; Selección del multiplexor MUX2
    flash_point_Z_plus_param MEAS_RANGE_FLASH_CONTINUE_MUX2_VALUES
    lpm     R0,Z
    set_MUX2_with_R0_value

    ; Deshabilitación del Timer0 como PWM
    ldi     tmp,PWM_OFF_PWM_CONFIG
    out     TCCR0,tmp   ; Deshabilita el PWM en modo rápido
    in      tmp,TIMSK
    cbr     tmp,PWM_OV_INTERRUPT_MASK
    out     TIMSK,tmp   ; Deshabilita la interrupción de overflow Timer0

    ; Corriente continua máxima, 0 en un sentido, 1 en otro
    ; TODO: ver cuál es el correcto
    sbi     PORTB,PORTB3
    ;cbi     PORTB,PORTB3

    pop     ZL
    pop     ZH
    pop     R0 ; Registros recuperados del stack
    ret
