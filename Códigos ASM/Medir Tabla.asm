#ifdef AVRA
    .nolist
    .include "m328def.inc"
    .list
#endif

;||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||;
;||||||||||||||||||||||||||||||||| Constantes |||||||||||||||||||||||||||||||||;
;||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||;
.equ N_PERIODS_TO_SAMPLE = 9
.equ SAMPLES_PER_PERIOD = 28
.equ SAMPLES_TABLE_LEN = (N_PERIODS_TO_SAMPLE * SAMPLES_PER_PERIOD)


;|//////////////////////////////////////|\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\|;
;|//////////////////////| Direcciones reservadas en RAM |\\\\\\\\\\\\\\\\\\\\\|;
;|//////////////////////////////////////|\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\|;
.dseg
.org SRAM_START
SAMPLES_RAM_TABLE: ; Tabla: entrada del ADC muestreada
    .byte SAMPLES_TABLE_LEN
MAX_TABLE: ; Tabla: máximos de cada período, se ordenará para obtener la mediana
    .byte N_PERIODS_TO_SAMPLE
MIN_TABLE: ; Tabla: mínimos de cada período, se ordenará para obtener la mediana
    .byte N_PERIODS_TO_SAMPLE


;|//////////////////////////////////////|\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\|;
;|////////////////////////| Vector de interrupciones |\\\\\\\\\\\\\\\\\\\\\\\\|;
;|//////////////////////////////////////|\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\|;
.cseg

; Interrupción reset -> MAIN
.org 0x0
    jmp     MAIN

; Final del vector de interrupciones
.org INT_VECTORS_SIZE


;|//////////////////////////////////////|\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\|;
;|/////////////////////////////| Datos en flash |\\\\\\\\\\\\\\\\\\\\\\\\\\\\\|;
;|//////////////////////////////////////|\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\|;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Solo para testear, se cargan estos datos en RAM, generados con octave ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
TEST_SAMPLES_FLASH_TABLE:
    .db 0x82, 0x95, 0xAC, 0xC2, 0xCC, 0xD5, 0xE0, 0xE7, 0xE3, 0xD8, 0xCE, 0xC3
    .db 0xAA, 0x9A, 0x81, 0x66, 0x55, 0x44, 0x30, 0x29, 0x1B, 0x1D, 0x1B, 0x27
    .db 0x2D, 0x44, 0x57, 0x6C, 0x84, 0x93, 0xA7, 0xBC, 0xD2, 0xDC, 0xE0, 0xE4
    .db 0xE2, 0xDE, 0xD1, 0xBB, 0xAF, 0x95, 0x7F, 0x6D, 0x54, 0x41, 0x33, 0x28
    .db 0x1A, 0x1F, 0x1F, 0x27, 0x31, 0x45, 0x50, 0x66, 0x7D, 0x96, 0xAC, 0xBA
    .db 0xD0, 0xDF, 0xDD, 0xE4, 0xDE, 0xD9, 0xCC, 0xBC, 0xAC, 0x9A, 0x7F, 0x69
    .db 0x57, 0x3F, 0x2E, 0x23, 0x1C, 0x1A, 0x1A, 0x25, 0x2D, 0x3E, 0x54, 0x6B
    .db 0x7D, 0x93, 0xB0, 0xBA, 0xCB, 0xDA, 0xE6, 0xE1, 0xE4, 0xD8, 0xD2, 0xBB
    .db 0xAC, 0x98, 0x7D, 0x69, 0x50, 0x46, 0x2F, 0x28, 0x20, 0x1B, 0x1D, 0x2A
    .db 0x2F, 0x45, 0x56, 0x6D, 0x83, 0x9B, 0xAF, 0xC3, 0xCE, 0xDC, 0xDD, 0xE4
    .db 0xE3, 0xD9, 0xCC, 0xBF, 0xAE, 0x93, 0x83, 0x6D, 0x57, 0x40, 0x36, 0x26
    .db 0x1F, 0x18, 0x1B, 0x24, 0x31, 0x45, 0x54, 0x68, 0x83, 0x97, 0xA6, 0xBF
    .db 0xD1, 0xD9, 0xDE, 0xE8, 0xE5, 0xD6, 0xCF, 0xC1, 0xAD, 0x92, 0x81, 0x65
    .db 0x59, 0x3D, 0x32, 0x28, 0x22, 0x18, 0x21, 0x21, 0x30, 0x46, 0x51, 0x65
    .db 0x7E, 0x95, 0xAF, 0xC0, 0xCE, 0xD7, 0xE5, 0xE7, 0xDF, 0xD9, 0xD2, 0xC2
    .db 0xAE, 0x95, 0x81, 0x6D, 0x51, 0x43, 0x30, 0x28, 0x1E, 0x1A, 0x1C, 0x25
    .db 0x30, 0x3E, 0x55, 0x6C, 0x7C, 0x95, 0xAD, 0xBF, 0xCC, 0xDD, 0xE6, 0xE2
    .db 0xE0, 0xDB, 0xCD, 0xBF, 0xAB, 0x9B, 0x7F, 0x6B, 0x58, 0x3F, 0x35, 0x25
    .db 0x1B, 0x1F, 0x20, 0x2A, 0x31, 0x3D, 0x57, 0x6C, 0x7D, 0x97, 0xAA, 0xC1
    .db 0xD3, 0xD6, 0xE3, 0xE0, 0xDD, 0xD9, 0xD2, 0xBF, 0xAD, 0x97, 0x7D, 0x67
    .db 0x52, 0x45, 0x2E, 0x26, 0x23, 0x1A, 0x1A, 0x29, 0x36, 0x3F, 0x51, 0x68


;||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||;
;|||||||||||||||||||||||||||||||||||| Main ||||||||||||||||||||||||||||||||||||;
;||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||;
; R16 es un registro temporario, siempre se podrá pisar sin salvarlo
MAIN:
    ldi     R16,HIGH(RAMEND)
    out     SPH,R16
    ldi     R16,LOW(RAMEND)
    out     SPL,R16 ; Stack pointer

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;;; Solo para testear, se cargan estos datos en RAM, generados con octave ;;
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ldi     ZH,HIGH(TEST_SAMPLES_FLASH_TABLE<<1)
    ldi     ZL,LOW(TEST_SAMPLES_FLASH_TABLE<<1)
    ldi     XH,HIGH(SAMPLES_RAM_TABLE)
    ldi     XL,LOW(SAMPLES_RAM_TABLE)
    ldi     R16,SAMPLES_TABLE_LEN
loop_test_samples_table:
    lpm     R17,Z+
    st      X+,R17
    dec     R16
    brne    loop_test_samples_table
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    rcall   SEARCH_FOR_LOCAL_EXTREMES_AND_LOAD_MIN_MAX_TABLES

    ldi     R16,N_PERIODS_TO_SAMPLE ; Cantidad de elementos en tablas MIN/MAX
    ldi     ZH,HIGH(MAX_TABLE)
    ldi     ZL,LOW(MAX_TABLE) ; Puntero a la tabla de máximos
    rcall   CALCULATE_TO_R1_MEDIAN_IN_TABLE_POINTED_BY_Z_LENGTH_IN_R16
    mov     R2,R1             ; R2 = MAX

    ldi     ZH,HIGH(MIN_TABLE)
    ldi     ZL,LOW(MIN_TABLE) ; Puntero a la tabla de mínimos
    rcall   CALCULATE_TO_R1_MEDIAN_IN_TABLE_POINTED_BY_Z_LENGTH_IN_R16
    ; R1 = MIN, se procede a calcular el valor pico como (MAX-MIN)/2
    sub     R2,R1
    lsr     R2                ; R2 contiene el valor pico de la medición

here:
    rjmp    here


;------------------------------------------------------------------------------;
;--------- Búsqueda de extremos locales (máximo y mínimo por período) ---------;
;------------------------------------------------------------------------------;
;
; Genera MAX_TABLE y MIN_TABLE con los máximos y mínimos locales de cada
; período, luego las tablas son ordenadas por otra rutina para encontrar
; ambas medianas. Salva todos los registros que arruina.
;
SEARCH_FOR_LOCAL_EXTREMES_AND_LOAD_MIN_MAX_TABLES:
    push    R1
    push    R2
    push    R3
    push    R17
    push    R18
    push    XH
    push    XL
    push    YH
    push    YL
    push    ZH
    push    ZL ; Registros salvados en el stack

    ldi     XH,HIGH(SAMPLES_RAM_TABLE)
    ldi     XL,LOW(SAMPLES_RAM_TABLE) ; Puntero a la tabla de muestras
    ldi     YH,HIGH(MAX_TABLE)
    ldi     YL,LOW(MAX_TABLE) ; Puntero a la tabla de máximos
    ldi     ZH,HIGH(MIN_TABLE)
    ldi     ZL,LOW(MIN_TABLE) ; Puntero a la tabla de mínimos

    ldi     R17,N_PERIODS_TO_SAMPLE ; Contador para cada período
loop_periods:
    ldi     R18,SAMPLES_PER_PERIOD ; Contador para cada sample en un período
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
    dec     R18   ; Decremento del contador de samples
    brne    loop_samples_one_period
    ; En este punto, el máximo del período está en R2 y el mínimo en R3
    st      Y+,R2  ; Agregado del máximo en la tabla y post incremento
    st      Z+,R3  ; Agregado del mínimo en la tabla y post incremento
    dec     R17    ; Decremento del contador de períodos
    brne    loop_periods

    pop     ZL
    pop     ZH
    pop     YL
    pop     YH
    pop     XL
    pop     XH
    pop     R18
    pop     R17
    pop     R3
    pop     R2
    pop     R1 ; Registros recuperados del stack
    ret


;------------------------------------------------------------------------------;
;------ Obtención de la mediana de la tabla apuntada por Z, de largo R16 ------;
;------------------------------------------------------------------------------;
;
; Ordena por el método de burbujeo una tabla de enteros no signados en memoria,
; apuntada por Z, de largo R16. Luego toma el valor del medio para el caso en
; que la cantidad de elementos sea impar, o el izquierdo de los dos centrales,
; en el caso en que la cantidad de elementos es par. De esta forma devuelve la
; mediana en R1. Salva todos los registros que arruina, incluso R16 y Z.
; NOTA: en el caso en que la cantidad de elementos fuera par, debería devolver
; la media aritmética de ambos valores centrales, pero este caso no se va a dar.
;
CALCULATE_TO_R1_MEDIAN_IN_TABLE_POINTED_BY_Z_LENGTH_IN_R16:
    push    R2
    push    R3
    push    R17
    push    YH
    push    YL ; Registros salvados en el stack

    ; Ordenamiento por burbujeo, en una tabla pequeña no es un algoritmo tan
    ; ineficiente, para la aplicación se justifica
table_has_changed_loop:
    clt ; El flag T de SREG indicará si la tabla ha cambiado, en principio no
    mov     R17,R16 ; Se inicializa el contador
    dec     R17     ; Se va a mirar uno hacia adelante, se recorrerá uno menos
    mov     YH,ZH
    mov     YL,ZL   ; Se inicializa el puntero Y en Z
loop_table_elements:
    ld      R2,Y    ; Carga un elemento de la tabla
    ldd     R3,Y+1  ; Carga el siguiente elemento de la tabla
    cp      R3,R2   ; Compara, si R3 >= R2, no hay que intercambiarlos
    brsh    do_not_interchange
    set ; La tabla va a cambiar, entonces se indica en el flag T
    st      Y,R3    ; En la primera posición se pone la segunda
    std     Y+1,R2  ; En la segunda posición se pone la primera
do_not_interchange:
    ld      R2,Y+   ; Incremento de Y, arruina R2 pero este valor no es usado
    dec     R17     ; Decremento del contador
    brne    loop_table_elements
    brts    table_has_changed_loop

    ; En este punto la tabla está ordenada, ahora la mediana se obtendrá de
    ; la mitad de la misma
    mov     R17,R16
    asr     R17     ; R17 tiene el valor de la mitad de la tabla
    mov     YH,ZH
    mov     YL,ZL   ; Se inicializa el puntero Y en Z
    add     YL,R17  ; Se le suma a Y el lugar de la mitad de la tabla
    brcc    skip_ZH_increase
    inc     YH      ; Se actualiza la parte alta de Y de ser necesario
skip_ZH_increase:
    ld      R1,Y    ; Finalmente se obtiene la mediana en R1 para devolverla

    pop     YL
    pop     YH
    pop     R17
    pop     R3
    pop     R2 ; Registros recuperados del stack
    ret
