;||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||;
;||||||||| Interrupción de actualización del ciclo de trabajo del PWM |||||||||;
;||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||;
PWM_DUTY_CYCLE_UPDATE_ISR:
    ld      tmp,X+    ; Próximo valor del ciclo de trabajo desde RAM
    out     OCR0,tmp  ; Valor actualizado de ciclo de trabajo
    dec     tbl_i     ; Decremento del iterador de la tabla en RAM
    brne    skip_go_beginning ; Saltea si tbl_i no es cero
    rcall   SINE_RAM_TABLE_GO_BEGINNING
skip_go_beginning:
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
    push    iter
    push    ZH
    push    ZL
    push    XH
    push    XL ; Registros salvados en el stack

    ldi     ZH,HIGH(PWM_SINE_FLASH_TABLE<<1)
    ldi     ZL,LOW(PWM_SINE_FLASH_TABLE<<1) ; Inicialización de puntero en flash
    ldi     XH,HIGH(PWM_SINE_RAM_TABLE)
    ldi     XL,LOW(PWM_SINE_RAM_TABLE) ; Inicialización de puntero en RAM

    ldi     iter,PWM_SINE_TABLE_LEN    ; Contador
loop_sine_table:
    lpm     tmp,Z+    ; Lectura desde flash, del sample original
    mulsu   tmp,param ; Sample escalado y multiplicado x 128 en R1:R0
    rol     R0 ;> División por 128: se multiplica por 2 el entero de 16 bits
    rol     R1 ;> con shifts y luego se divide por 256 quedándose con R1 (MSB)
    ldi     tmp,PWM_SINE_MEDIAN
    add     R1,tmp    ; En R1 queda el sample más la media
    st      X+,R1     ; Carga en RAM del sample final
    dec     iter      ; Decremento del contador
    brne    loop_sine_table

    pop     XL
    pop     XH
    pop     ZL
    pop     ZH
    pop     iter
    pop     R1
    pop     R0 ; Registros recuperados del stack
    ret


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
.macro point_Z_plus_param_offset
    ldi     ZH,HIGH(@0<<1)
    ldi     ZL,LOW(@0<<1) ; Puntero en flash

    clr     tmp      ; Se borra el registro temporario
    add     ZL,param ; Se desplaza en la tabla según el parámetro de entrada
    adc     ZH,tmp   ; Se suma el acarreo a la parte alta (tmp = 0)
.endmacro

PWM_SINE_START:
    push    R0
    push    param
    push    ZH
    push    ZL ; Registros salvados en el stack

    ; Selección del multiplexor MUX2
    point_Z_plus_param_offset MEAS_RANGE_FLASH_MUX2_VALUES
    lpm     R0,Z
    in      tmp,PORTB
    cbr     tmp,(1<<PORTB0)|(1<<PORTB1)
    or      tmp,R0
    out     PORTB,tmp

    ; Creación de tabla en RAM
    point_Z_plus_param_offset MEAS_RANGE_FLASH_SINAMPS
    lpm     param,Z  ; Valor correspondiente de amplitud para la rutina
    rcall   LOAD_SINE_RAM_TABLE_SCALED

    ; Inicialización del puntero X y el contador tbl_i, no se pueden usar más!
    rcall   SINE_RAM_TABLE_GO_BEGINNING

    ; Configuración del Timer0 como PWM
    ldi     tmp,PWM_FAST_PWM_CONFIG
    out     TCCR0,tmp
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
PWM_SINE_STOP:
    ; Configuración del Timer0 como PWM
    ldi     tmp,PWM_FAST_PWM_CONFIG
    out     TCCR0,tmp
    in      tmp,TIMSK
    cbr     tmp,PWM_OV_INTERRUPT_MASK
    out     TIMSK,tmp   ; Deshabilita la interrupción de overflow Timer0

    ldi     tmp,PWM_SINE_MEDIAN
    out     OCR0,tmp    ; Pone el valor medio en la salida

    ret
