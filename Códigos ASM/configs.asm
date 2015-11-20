;||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||;
;||||||||||||||||||||||||||||||||| Constantes |||||||||||||||||||||||||||||||||;
;||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||;

;---------------------------- Configuración del PWM ---------------------------;
;
; Compare Output Mode: COM01:COM00 = 1:0 => Clear OC0 on compare match
; Waveform Generation Mode: WGM01:WGM00 1:1 => Fast PWM
; Clock select: CS02:CS01:CS00 = 0:0:1 => CPU clock, no prescaling
;
; Timer/Counter0 Control Register:
;     |  FOC0  | WGM00  | COM01  | COM00  | WGM01  |  CS02  |  CS01  |  CS00  |
;     |    0   |    1   |    1   |    0   |    1   |    0   |    0   |    1   |
;
; Timer/Counter Interrupt Mask Register:
;     |  OCIE2 |  TOIE2 | TICIE1 | OCIE1A | OCIE1B |  TOIE1 |  OCIE0 |  TOIE0 |
;          0        0        0        0        0        0        0        1
;
.equ PWM_FAST_PWM_CONFIG   = (1<<COM01)|(1<<WGM01)|(1<<WGM00)|(1<<CS00)
.equ PWM_OFF_PWM_CONFIG    = 0
.equ PWM_OV_INTERRUPT_MASK = (1<<TOIE0)
.equ PWM_SINE_TABLE_LEN    = 72
.equ PWM_SINE_MEDIAN       = 127

;--------------------- Configuración de rangos de medición --------------------;
; Valores del multiplexor MUX2
.equ MUX2_x30nA  = 0
.equ MUX2_x80nA  = 1
.equ MUX2_x120nA = 2
.equ MUX2_x200nA = 3

; Enumerativo para los rangos de medición
.equ MEAS_RANGE_2  = 0
.equ MEAS_RANGE_8  = 1
.equ MEAS_RANGE_20 = 2
.equ MEAS_RANGE_60 = 3

;---------------------------- Registros especiales ----------------------------;
.def tmp   = R16        ; Temporario, siempre se podrá pisar sin salvarlo
.def param = R17        ; Parámetro para rutinas
.def tbl_i = R18        ; Iterador de la tabla en RAM, siempre en uso!
.def iter  = R19        ; Iterador, múltiple uso, salvar al pisarlo


; Registros siempre en uso por interrupciones, no usar para otra cosa!:
; R18, X (R26:R27)


;|//////////////////////////////////////|\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\|;
;|//////////////////////| Direcciones reservadas en RAM |\\\\\\\\\\\\\\\\\\\\\|;
;|//////////////////////////////////////|\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\|;
.dseg
.org SRAM_START
PWM_SINE_RAM_TABLE: ; Tabla: seno escalado, listo para actualizar el PWM
    .byte PWM_SINE_TABLE_LEN


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
PWM_SINE_FLASH_TABLE:
    .db 0x00, 0x0B, 0x16, 0x21, 0x2B, 0x36, 0x3F, 0x49, 0x52, 0x5A, 0x61, 0x68
    .db 0x6E, 0x73, 0x77, 0x7B, 0x7D, 0x7F, 0x7F, 0x7F, 0x7D, 0x7B, 0x77, 0x73
    .db 0x6E, 0x68, 0x61, 0x5A, 0x52, 0x49, 0x3F, 0x36, 0x2B, 0x21, 0x16, 0x0B
    .db 0x00, 0xF5, 0xEA, 0xDF, 0xD5, 0xCA, 0xC1, 0xB7, 0xAE, 0xA6, 0x9F, 0x98
    .db 0x92, 0x8D, 0x89, 0x85, 0x83, 0x81, 0x81, 0x81, 0x83, 0x85, 0x89, 0x8D
    .db 0x92, 0x98, 0x9F, 0xA6, 0xAE, 0xB7, 0xC0, 0xCA, 0xD5, 0xDF, 0xEA, 0xF5

; === Multiplexor MUX2 para cada rango de medición ===
MEAS_RANGE_FLASH_MUX2_VALUES:
    .db MUX2_x200nA, MUX2_x80nA, MUX2_x30nA, MUX2_x30nA

; === Valor de amplitud para cada rango de medición ===
; 128 --> 100,0 % --> 200,0 nA de corriente pico
;  84 -->  65,6 % -->  52,5 nA de corriente pico
;  92 -->  71,9 % -->  21,6 nA de corriente pico
;  30 -->  23,4 % -->   7,0 nA de corriente pico
MEAS_RANGE_FLASH_SINAMPS:
    .db 128, 84, 92, 30
