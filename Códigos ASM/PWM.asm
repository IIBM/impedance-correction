#ifdef AVRA
    .nolist
    .include "m328def.inc"
    .list
#endif

;||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||;
;||||||||||||||||||||||||||||||||| Constantes |||||||||||||||||||||||||||||||||;
;||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||;
.equ SINE_TABLE_LEN = 72
.equ    SINE_MEDIAN = 128


;|//////////////////////////////////////|\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\|;
;|//////////////////////| Direcciones reservadas en RAM |\\\\\\\\\\\\\\\\\\\\\|;
;|//////////////////////////////////////|\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\|;
.dseg
.org SRAM_START
SINE_RAM_TABLE: ; Tabla: seno escalado, listo para actualizar el PWM
    .byte SINE_TABLE_LEN


;|//////////////////////////////////////|\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\|;
;|////////////////////////| Vector de interrupciones |\\\\\\\\\\\\\\\\\\\\\\\\|;
;|//////////////////////////////////////|\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\|;
.cseg

; Interrupción reset -> MAIN
.org 0x0
    jmp     MAIN

; Interrupción de overflow del Timer0
.org OVF0addr
    jmp     PWM_DUTY_CYCLE_UPDATE_ISR

; Final del vector de interrupciones
.org INT_VECTORS_SIZE


;|//////////////////////////////////////|\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\|;
;|/////////////////////////////| Datos en flash |\\\\\\\\\\\\\\\\\\\\\\\\\\\\\|;
;|//////////////////////////////////////|\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\|;
SINE_FLASH_TABLE:
    .db 0x00, 0x0B, 0x16, 0x21, 0x2B, 0x36, 0x3F, 0x49, 0x52, 0x5A, 0x61, 0x68
    .db 0x6E, 0x73, 0x77, 0x7B, 0x7D, 0x7F, 0x7F, 0x7F, 0x7D, 0x7B, 0x77, 0x73
    .db 0x6E, 0x68, 0x61, 0x5A, 0x52, 0x49, 0x3F, 0x36, 0x2B, 0x21, 0x16, 0x0B
    .db 0x00, 0xF5, 0xEA, 0xDF, 0xD5, 0xCA, 0xC1, 0xB7, 0xAE, 0xA6, 0x9F, 0x98
    .db 0x92, 0x8D, 0x89, 0x85, 0x83, 0x81, 0x81, 0x81, 0x83, 0x85, 0x89, 0x8D
    .db 0x92, 0x98, 0x9F, 0xA6, 0xAE, 0xB7, 0xC0, 0xCA, 0xD5, 0xDF, 0xEA, 0xF5


;||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||;
;|||||||||||||||||||||||||||||||||||| Main ||||||||||||||||||||||||||||||||||||;
;||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||;
; R16 es un registro temporario, siempre se podrá pisar sin salvarlo
MAIN:
    ldi     R16,HIGH(RAMEND)
    out     SPH,R16
    ldi     R16,LOW(RAMEND)
    out     SPL,R16 ; Stack pointer
    sei     ; Habilita las interrupciones (global)

    ldi     R16,64 ; Escala de senoidal 64/128 = 50%
    rcall   LOAD_SINE_RAM_TABLE_SCALED_BY_R16

    rcall   SINE_RAM_TABLE_GO_BEGINNING

    rcall   MAKE_PWM_CONFIG

bussy_loop:
    rjmp    bussy_loop


;==============================================================================;
;--------- Interrupción de actualización del ciclo de trabajo del PWM ---------;
;==============================================================================;
PWM_DUTY_CYCLE_UPDATE_ISR:
    ld      R16,X+    ; Próximo valor del ciclo de trabajo desde RAM
    out     OCR0A,R16 ; Valor actualizado de ciclo de trabajo
    dec     R18       ; Decremento del iterador de la tabla en RAM
    brne    skip_go_beginning ; Saltea si R18 no es cero
    rcall   SINE_RAM_TABLE_GO_BEGINNING
skip_go_beginning:
    reti


;------------------------------------------------------------------------------;
;----- Apuntado de la tabla del seno en RAM e inicialización del contador -----;
;------------------------------------------------------------------------------;
SINE_RAM_TABLE_GO_BEGINNING:
    ldi     XH,HIGH(SINE_RAM_TABLE)
    ldi     XL,LOW(SINE_RAM_TABLE) ; Tabla de onda escalada en RAM
    ldi     R18,SINE_TABLE_LEN ; Contador iterador de la tabla en RAM
    ret


;------------------------------------------------------------------------------;
;------------------------- Carga de la tabla del seno -------------------------;
;------------------------------------------------------------------------------;
;
; R16 <- escalado de amplitud x 128, ejemplo: 25% = 32/128 => R16 = 32
; Al finalizar la tabla estará cargada en SINE_RAM_TABLE, escalada por R16/128
; y con un valor medio de SINE_MEDIAN. Salva todos los registros que arruina.
;
LOAD_SINE_RAM_TABLE_SCALED_BY_R16:
    push    R0
    push    R1
    push    R17
    push    R18
    push    ZH
    push    ZL
    push    XH
    push    XL ; Registros salvados en el stack

    ldi     ZH,HIGH(SINE_FLASH_TABLE<<1)
    ldi     ZL,LOW(SINE_FLASH_TABLE<<1) ; Inicialización de puntero en flash
    ldi     XH,HIGH(SINE_RAM_TABLE)
    ldi     XL,LOW(SINE_RAM_TABLE) ; Inicialización de puntero en RAM

    ldi     R18,SINE_TABLE_LEN ; Contador
loop_sine_table:
    lpm     R17,Z+  ; Lectura desde flash, del sample original
    mulsu   R17,R16 ; Sample escalado y multiplicado x 128 en R1:R0
    rol     R0 ;> División por 128: se multiplica por 2 el entero de 16 bits
    rol     R1 ;> con shifts y luego se divide por 256 quedándose con R1 (MSB)
    ldi     R17,SINE_MEDIAN
    add     R1,R17  ; En R1 queda el sample más la media
    st      X+,R1   ; Carga en RAM del sample final
    dec     R18     ; Decremento del contador
    brne    loop_sine_table

    pop     XL
    pop     XH
    pop     ZL
    pop     ZH
    pop     R18
    pop     R17
    pop     R1
    pop     R0 ; Registros recuperados del stack
    ret


;------------------------------------------------------------------------------;
;---------------------------- Configuración del PWM ---------------------------;
;------------------------------------------------------------------------------;
;
; Compare Output Mode: COM0A1:COM0A0 = 1:0 => Clear OC0B on compare match
; Waveform Generation Mode: WGM02:WGM01:WGM00 0:1:1 => Fast PWM
; Clock select: CS02:CS01:CS00 = 0:0:1 => CPU clock, no prescaling
;
; Timer/Counter0 Control Register A:
;     | COM0A1 | COM0A0 | COM0B1 | COM0B0 | *Res*  | *Res*  | WGM01  | WGM00  |
;     |    1   |    0   |    0   |    0   |    0   |    0   |    1   |    1   |
;
; Timer/Counter0 Control Register B:
;     | FOC0A  | FOC0B  | *Res*  | *Res*  | WGM02  |  CS02  |  CS01  |  CS00  |
;     |    0   |    0   |    0   |    0   |    0   |    0   |    0   |    1   |
;
MAKE_PWM_CONFIG:
    sbi     DDRD,PORTD6 ; Puerto D6 como salida del PWM
    ldi     R16,(1<<COM0A1)|(1<<WGM01)|(1<<WGM00)
    out     TCCR0A,R16
    ldi     R16,(1<<CS00)
    out     TCCR0B,R16
    ldi     R16,(1<<TOIE0)
    sts     TIMSK0,R16 ; Habilita la interrupción de overflow Timer0
    ret
