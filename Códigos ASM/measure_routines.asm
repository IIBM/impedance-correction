;|//////////////////////////////////////|\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\|;
;|///////| Búsqueda de extremos locales (máximo y mínimo por período) |\\\\\\\|;
;|//////////////////////////////////////|\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\|;
;
; Genera ADC_MAXS_RAM_TABLE y ADC_MINS_RAM_TABLE con los máximos y mínimos
; locales de cada período, luego las tablas son ordenadas por otra rutina para
; encontrar ambas medianas. Salva todos los registros que arruina.
;
SEARCH_FOR_LOCAL_EXTREMES_AND_LOAD_MIN_MAX_TABLES:
    push    R1
    push    R2
    push    R3
    push    iter
    push    iter2
    push    XH
    push    XL
    push    YH
    push    YL
    push    ZH
    push    ZL ; Registros salvados en el stack

    ldi     XH,HIGH(ADC_SAMPLES_RAM_TABLE)
    ldi     XL,LOW(ADC_SAMPLES_RAM_TABLE) ; Puntero a la tabla de muestras
    ldi     YH,HIGH(ADC_MAXS_RAM_TABLE)
    ldi     YL,LOW(ADC_MAXS_RAM_TABLE)    ; Puntero a la tabla de máximos
    ldi     ZH,HIGH(ADC_MINS_RAM_TABLE)
    ldi     ZL,LOW(ADC_MINS_RAM_TABLE)    ; Puntero a la tabla de mínimos

    ldi     iter,ADC_PERIODS_TO_SAMPLE    ; Contador para cada período
loop_periods:
    ldi     iter2,ADC_SAMPLES_PER_PERIOD  ; Contador para cada sample
    ld      R2,X  ; Registro para alojar el máximo, se carga con el primer valor
    ld      R3,X  ; Registro para alojar el mínimo, se carga con el primer valor
loop_samples_one_period:
    ; Se buscará mínimo y máximo (enteros no signados) dentro de este loop
    ld      R1,X+ ; Carga de un sample y post incremento
    cp      R2,R1 ; Si R2 >= R1 NO hay que actualizar el máximo (R2)
    brsh    skip_update_max
    mov     R2,R1 ; Actualización del máximo, si R1 > R2
skip_update_max:
    cp      R1,R3 ; Si R1 >= R3 NO hay que actualizar el mínimo (R3)
    brsh    skip_update_min
    mov     R3,R1 ; Actualización del mínimo, si R1 < R3
skip_update_min:
    dec     iter2 ; Decremento del contador de samples
    brne    loop_samples_one_period
    ; En este punto, el máximo del período está en R2 y el mínimo en R3
    st      Y+,R2 ; Agregado del máximo en la tabla y post incremento
    st      Z+,R3 ; Agregado del mínimo en la tabla y post incremento
    dec     iter  ; Decremento del contador de períodos
    brne    loop_periods

    pop     ZL
    pop     ZH
    pop     YL
    pop     YH
    pop     XL
    pop     XH
    pop     iter2
    pop     iter
    pop     R3
    pop     R2
    pop     R1 ; Registros recuperados del stack
    ret


;|//////////////////////////////////////|\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\|;
;|///| Obtención de la mediana de la tabla apuntada por Z, de largo param |\\\|;
;|//////////////////////////////////////|\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\|;
;
; param (R17) <- largo de la tabla apuntada por Z
; Ordena por el método de burbujeo una tabla de enteros no signados en memoria,
; apuntada por Z, de largo param (R17). Luego toma el valor del medio para el
; caso en que la cantidad de elementos sea impar, o el izquierdo de los dos
; centrales, en el caso en que la cantidad de elementos es par. De esta forma
; devuelve la mediana en R1. Salva todos los registros que arruina, incluso R17
; y Z. NOTA: en el caso en que la cantidad de elementos fuera par, debería
; devolver la media aritmética de ambos valores centrales, pero este caso no se
; va a dar.
;
CALCULATE_TO_R1_MEDIAN_IN_TABLE_POINTED_BY_Z_LENGTH_IN_PARAM:
    push    R2
    push    R3
    push    iter
    push    YH
    push    YL ; Registros salvados en el stack

    ; Ordenamiento por burbujeo, en una tabla pequeña no es un algoritmo tan
    ; ineficiente, para la aplicación se justifica
table_has_changed_loop:
    clt ; El flag T de SREG indicará si la tabla ha cambiado, en principio no
    mov     iter,param ; Se inicializa el contador
    dec     iter       ; Se mirará uno hacia adelante, se recorrerá uno menos
    mov     YH,ZH
    mov     YL,ZL      ; Se inicializa el puntero Y en Z
loop_table_elements:
    ld      R2,Y       ; Carga un elemento de la tabla
    ldd     R3,Y+1     ; Carga el siguiente elemento de la tabla
    cp      R3,R2      ; Compara, si R3 >= R2, no hay que intercambiarlos
    brsh    do_not_interchange
    set ; La tabla va a cambiar, entonces se indica en el flag T
    st      Y,R3       ; En la primera posición se pone la segunda
    std     Y+1,R2     ; En la segunda posición se pone la primera
do_not_interchange:
    adiw    YL,1       ; Incremento de Y
    dec     iter       ; Decremento del contador
    brne    loop_table_elements
    brts    table_has_changed_loop

    ; En este punto la tabla está ordenada, ahora la mediana se obtendrá de
    ; la mitad de la misma
    clr     R2
    mov     tmp,param
    asr     tmp        ; tmp/2: índice de la mitad de la tabla
    mov     YH,ZH
    mov     YL,ZL      ; Se inicializa el puntero Y en Z
    add     YL,tmp     ; Se le suma a Y el lugar de la mitad de la tabla
    adc     YH,R2      ; Se suma el acarreo a la parte alta (R2 = 0)
    ld      R1,Y       ; Finalmente se obtiene la mediana en R1 para devolverla

    pop     YL
    pop     YH
    pop     iter
    pop     R3
    pop     R2 ; Registros recuperados del stack
    ret


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;; Solo para testear, se cargan estos datos en RAM, generados con octave ;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
TEST_SAMPLES_FLASH_TABLE:
    .db 0x81, 0x90, 0xA2, 0xAF, 0xC0, 0xC9, 0xD5, 0xDB, 0xE2, 0xE4, 0xE5, 0xDE
    .db 0xD9, 0xD2, 0xC4, 0xB7, 0xAB, 0x98, 0x87, 0x77, 0x66, 0x56, 0x48, 0x3B
    .db 0x30, 0x29, 0x1F, 0x1E, 0x1B, 0x1C, 0x22, 0x2A, 0x36, 0x40, 0x50, 0x5E
    .db 0x6F, 0x7E, 0x92, 0xA2, 0xAF, 0xBF, 0xCC, 0xD3, 0xDD, 0xE0, 0xE4, 0xE4
    .db 0xE0, 0xD9, 0xD1, 0xC6, 0xB9, 0xA9, 0x99, 0x8B, 0x77, 0x67, 0x57, 0x48
    .db 0x3D, 0x2F, 0x25, 0x20, 0x1B, 0x1E, 0x20, 0x23, 0x2C, 0x34, 0x40, 0x4E
    .db 0x5F, 0x6F, 0x80, 0x8F, 0xA2, 0xB1, 0xC0, 0xCB, 0xD5, 0xDA, 0xE3, 0xE3
    .db 0xE2, 0xDF, 0xDA, 0xD0, 0xC5, 0xBA, 0xAC, 0x9D, 0x89, 0x79, 0x69, 0x56
    .db 0x4A, 0x3C, 0x31, 0x29, 0x22, 0x1D, 0x1D, 0x1E, 0x21, 0x2B, 0x34, 0x41
    .db 0x4C, 0x5E, 0x6F, 0x7C, 0x8F, 0xA0, 0xAD, 0xBF, 0xC9, 0xD5, 0xDA, 0xE1
    .db 0xE3, 0xE5, 0xE0, 0xDB, 0xD2, 0xC6, 0xB9, 0xAC, 0x9B, 0x8B, 0x7C, 0x67
    .db 0x5A, 0x4C, 0x3D, 0x30, 0x29, 0x23, 0x1E, 0x1B, 0x1C, 0x24, 0x28, 0x35
    .db 0x3D, 0x4B, 0x5E, 0x6C, 0x7F, 0x8D, 0xA0, 0xAE, 0xBF, 0xCA, 0xD6, 0xDA
    .db 0xE3, 0xE4, 0xE2, 0xE0, 0xDB, 0xD1, 0xC7, 0xBB, 0xAE, 0x9B, 0x8C, 0x79
    .db 0x68, 0x5A, 0x4A, 0x3C, 0x2F, 0x2A, 0x22, 0x1C, 0x1B, 0x1F, 0x24, 0x28
    .db 0x31, 0x3F, 0x4C, 0x5D, 0x6C, 0x7E, 0x8F, 0x9D, 0xAE, 0xBC, 0xC8, 0xD2
    .db 0xDD, 0xE1, 0xE4, 0xE2, 0xE2, 0xDD, 0xD3, 0xC9, 0xBD, 0xAE, 0x9B, 0x8C
    .db 0x7B, 0x6A, 0x59, 0x4A, 0x3F, 0x32, 0x27, 0x20, 0x1E, 0x1C, 0x1E, 0x22
    .db 0x2B, 0x32, 0x3F, 0x4C, 0x5D, 0x6C, 0x7B, 0x8E, 0x9F, 0xAD, 0xBB, 0xCA
    .db 0xD2, 0xDB, 0xDF, 0xE3, 0xE4, 0xE0, 0xDA, 0xD2, 0xC8, 0xBB, 0xAD, 0x9E
    .db 0x8C, 0x7B, 0x6A, 0x5A, 0x4C, 0x3F, 0x31, 0x29, 0x22, 0x1D, 0x1D, 0x1D
    .db 0x22, 0x2A, 0x33, 0x3D, 0x4A, 0x5C, 0x6A, 0x7B, 0x8C, 0x9C, 0xAC, 0xBC
    .db 0xC7, 0xD4, 0xDA, 0xE2, 0xE2, 0xE4, 0xE2, 0xDC, 0xD5, 0xCA, 0xBD, 0xAE
    .db 0x9E, 0x8C, 0x7C, 0x6B, 0x59, 0x4C, 0x3D, 0x31, 0x2B, 0x20, 0x1F, 0x1D
    .db 0x1E, 0x23, 0x29, 0x31, 0x3F, 0x4C, 0x5C, 0x6A, 0x79, 0x8E, 0x9D, 0xAD
    .db 0xBB, 0xC8, 0xD3, 0xDB, 0xDF, 0xE3, 0xE2, 0xE1, 0xDA, 0xD3, 0xCB, 0xBC
    .db 0xB0, 0xA0, 0x8F, 0x7E, 0x6E, 0x5C, 0x4B, 0x3E, 0x34, 0x2B, 0x21, 0x1C
    .db 0x1E, 0x1D, 0x20, 0x29, 0x30, 0x3F, 0x4B, 0x59, 0x69, 0x00

TEST_SAMPLES_FLASH:
    ldi     ZH,HIGH(TEST_SAMPLES_FLASH_TABLE<<1)
    ldi     ZL,LOW(TEST_SAMPLES_FLASH_TABLE<<1)
    ldi     XH,HIGH(ADC_SAMPLES_RAM_TABLE)
    ldi     XL,LOW(ADC_SAMPLES_RAM_TABLE)
    ldi     YH,HIGH(ADC_SAMPLES_TABLE_LEN) ; Ojo: no es un puntero!
    ldi     YL,LOW(ADC_SAMPLES_TABLE_LEN)  ; Es un contador de 16 bits!
loop_test_samples_table:
    lpm     tmp,Z+
    st      X+,tmp
    sbiw    YL,1 ; Decremento del contador
    brne    loop_test_samples_table

    rcall   SEARCH_FOR_LOCAL_EXTREMES_AND_LOAD_MIN_MAX_TABLES

    ldi     param,ADC_PERIODS_TO_SAMPLE ; Cantidad de elementos en tablas
    ldi     ZH,HIGH(ADC_MAXS_RAM_TABLE)
    ldi     ZL,LOW(ADC_MAXS_RAM_TABLE)  ; Puntero a la tabla de máximos
    rcall   CALCULATE_TO_R1_MEDIAN_IN_TABLE_POINTED_BY_Z_LENGTH_IN_PARAM
    mov     R2,R1                       ; R2 = MAX

    ldi     ZH,HIGH(ADC_MINS_RAM_TABLE)
    ldi     ZL,LOW(ADC_MINS_RAM_TABLE)  ; Puntero a la tabla de mínimos
    rcall   CALCULATE_TO_R1_MEDIAN_IN_TABLE_POINTED_BY_Z_LENGTH_IN_PARAM
    ; R1 = MIN, se procede a calcular el valor pico como (MAX-MIN)/2
    sub     R2,R1
    lsr     R2                          ; R2 contiene el valor pico medido

here:
    rjmp    here
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
