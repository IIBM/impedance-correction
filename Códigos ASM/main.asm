#ifdef AVRA
    .nolist
    .include "m32def.inc"
    .list
#endif


.include "configs.asm"
.include "pwm.asm"
.include "adc.asm"


;||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||;
;|||||||||||||||||||||||||||||||||||| Main ||||||||||||||||||||||||||||||||||||;
;||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||;
MAIN:
    ldi     tmp,HIGH(RAMEND)
    out     SPH,tmp
    ldi     tmp,LOW(RAMEND)
    out     SPL,tmp  ; Stack pointer
    sei              ; Habilita las interrupciones (global)

;------------------------------------------------------------------------------;
;------------------------ Configuración de los puertos ------------------------;
;------------------------------------------------------------------------------;
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
;------------------------------------------------------------------------------;
;------------------------------------------------------------------------------;
    ldi     param,MEAS_RANGE_2
    rcall   PWM_SINE_START

here:
    rjmp    here
