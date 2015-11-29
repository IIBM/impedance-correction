#ifdef AVRA
    .nolist
    .include "m32def.inc"
    .list
#endif


.include "configs.asm"
.include "pwm.asm"
.include "adc.asm"
.include "measure_routines.asm"
.include "MEDIR.asm"
.include "LCD.asm"
.include "MENU.asm"


;||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||;
;|||||||||||||||||||||||||||||||||||| Main ||||||||||||||||||||||||||||||||||||;
;||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||;
MAIN:
    ldi     tmp,HIGH(RAMEND)
    out     SPH,tmp
    ldi     tmp,LOW(RAMEND)
    out     SPL,tmp  ; Stack pointer
    sei              ; Habilita las interrupciones (global)

;------------------------ Configuración de los puertos ------------------------;
;
;       PA0 --> RS  |                         PC0 --> D0  |
;       PA1 --> R/W | LCD                     PC1 --> D1  |
;       PA2 --> E   |                         PC2 --> D2  |
;       PA3 <-- ButtonLeft                    PC3 --> D3  | LCD
;       PA4 <-- ButtonRight                   PC4 --> D4  |
;       PA5 <-- ButtonOk                      PC5 --> D5  |
;       PA6 <== ADC: ImpedanceMeasure         PC6 --> D6  |
;       PA7 <== ADC: OffsetCalibration        PC7 --> D7  |
;
;
;       PB0 --> A   | MUX2                    PD0 --> S0  |
;       PB1 --> B   |                         PD1 --> S1  | MUX1
;       PB2 <== INT2: ButtonEsc               PD2 --> S2  |
;       PB3 ==> OC0: PWMSineWave              PD3 --> S3  |
;       PB4 --> S0  |                         PD4 *Unused*
;       PB5 --> S1  | MUX0                    PD5 *Unused*
;       PB6 --> S2  |                         PD6 *Unused*
;       PB7 --> S3  |                         PD7 ==> OC2: PWMOffsetAdjust
;
    ; Salidas y entradas
    ldi     tmp,0b00000111
    out     DDRA,tmp
    ldi     tmp,0b11111011
    out     DDRB,tmp
    ldi     tmp,0b11111111
    out     DDRC,tmp
    ldi     tmp,0b10001111
    out     DDRD,tmp

    ; Resistencias pull-up
    ldi     tmp,0b00111000
    out     PORTA,tmp
    ldi     tmp,0b00000100
    out     PORTB,tmp
    ldi     tmp,0b01110000
    out     PORTD,tmp


;------------------------------------------------------------------------------;
    call    PWM_OFFSET_START ; Se inicializa la referencia del OpAmp
    call    MENU

here:
    rjmp    here


;|//////////////////////////////////////|\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\|;
;|////////////////////////| Delay de 50 milisegundos |\\\\\\\\\\\\\\\\\\\\\\\\|;
;|//////////////////////////////////////|\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\|;
;
; Utiliza el Timer1. Solo usa el registro temporal, este nunca se salva.
;
DELAY_50ms:
    ldi     tmp,HIGH(TIMER1_50ms_DELAY_START)
    out     TCNT1H,tmp
    ldi     tmp,LOW(TIMER1_50ms_DELAY_START)
    out     TCNT1L,tmp                        ; Carga del contador del Timer1

    ldi     tmp,TIMER1_CLOCK_64_PRESCALER
    out     TCCR1B,tmp                        ; Activación del Timer1

keep_waiting:
    in      tmp,TIFR
    sbrs    tmp,TOV1      ; Saltea si el flag de overflow está encendido
    rjmp    keep_waiting

    ldi     tmp,TIMER1_OFF
    out     TCCR1B,tmp                        ; Desactivación del Timer1
    ldi     tmp,(1<<TOV1)
    out     TIFR,tmp                          ; Borrado del flag de overflow

    ret


;|//////////////////////////////////////|\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\|;
;|///////////////////////| Delay en segundos (1 a 255) |\\\\\\\\\\\\\\\\\\\\\\|;
;|//////////////////////////////////////|\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\|;
;
; param (R17) <- cantidad de segundos, 1 < param < 255
; Utiliza la rutina de delay de 50 ms. Salva todos los registros que arruina.
;
DELAY_PARAM_SECONDS:
    push    iter
    push    iter2 ; Registros salvados en el stack

    mov     iter,param ; Contador de segundos, se carga con el parámetro
loop_1s:
    ldi     iter2,20   ; Contador de 50 milisegundos: 20 * 50 ms = 1000 ms = 1 s
loop_50ms:
    rcall   DELAY_50ms
    dec     iter2      ; Decremento del contador de 50 milisegundos
    brne    loop_50ms  ; Si se contaron 20 vueltas de 50 ms se deja de repetir
    dec     iter       ; Decremento del contador de segundos
    brne    loop_1s    ; Si se contaron 60 vueltas de 1 s se deja de repetir

    pop     iter2
    pop     iter  ; Registros recuperados del stack
    ret
