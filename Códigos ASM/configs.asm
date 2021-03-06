;||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||;
;||||||||||||||||||||||||||||||||| Constantes |||||||||||||||||||||||||||||||||;
;||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||;

;---------------------------- Configuración del PWM ---------------------------;
;
; Compare Output Mode: COMn1:COMn0 = 1:0 => Clear OCn on compare match
; Waveform Generation Mode: WGMn1:WGMn0 1:1 => Fast PWM
; Clock select: CSn2:CSn1:CSn0 = 0:0:1 => CPU clock, no prescaling
;
; * Timer/Counter-n Control Register: (n = 0, 2. Timer/Counter0, Timer/Counter2)
;     |  FOCn  |  WGMn0 |  COMn1 |  COMn0 |  WGMn1 |  CSn2  |  CSn1  |  CSn0  |
;     |    0   |    1   |    1   |    0   |    1   |    0   |    0   |    1   |
;
; Timer0 Overflow Interrupt Enable: TOIE0 = 1 => Enabled
; Timer2 Overflow Interrupt Enable: TOIE2 = 0 => Disabled
;
; * Timer/Counter Interrupt Mask Register:
;     |  OCIE2 |  TOIE2 | TICIE1 | OCIE1A | OCIE1B |  TOIE1 |  OCIE0 |  TOIE0 |
;     |    x   |    0   |    x   |    x   |    x   |    x   |    x   |    1   |
;
.equ PWM_FAST_PWM_CONFIG_T1 = (1<<COM01) | (1<<WGM01) | (1<<WGM00) | (1<<CS00)
.equ PWM_FAST_PWM_CONFIG_T2 = (1<<COM21) | (1<<WGM21) | (1<<WGM20) | (1<<CS20)
.equ PWM_OFF_PWM_CONFIG     = 0
.equ PWM_OV_INTERRUPT_MASK  = (1<<TOIE0)
.equ PWM_SINE_TABLE_LEN     = 62
.equ PWM_SINE_MEDIAN        = 127

;--------------------- Configuración del Timer1 (16 bits) ---------------------;
;
; Waveform Generation Mode: WGM13:WGM12:WGM11:WGM10 0:0:0:0 => Normal mode
; Clock select: CS12:CS11:CS10 = 0:1:1 => CPU clock, divided by 64 -> 250 kHz
;
; * Timer/Counter1 Control Register A:
;     | COM1A1 | COM1A0 | COM1B1 | COM1B0 |  FOC1A |  FOC1B |  WGM11 |  WGM10 |
;     |    0   |    0   |    0   |    0   |    0   |    0   |    0   |    0   |
;
; * Timer/Counter1 Control Register B:
;     |  ICNC1 |  ICES1 |  *Res* |  WGM13 |  WGM12 |  CS12  |  CS11  |  CS10  |
;     |    0   |    0   |    0   |    0   |    0   |    0   |    1   |    1   |
;
.equ TIMER1_CLOCK_64_PRESCALER = (1<<CS11) | (1<<CS10)
.equ TIMER1_OFF                = 0
.equ TIMER1_50ms_DELAY_START   = -12500 ; 12500 / 250 kHz = 50 ms

;---------------------------- Configuración del ADC ---------------------------;
;
; Reference Selection: REFS1:REFS0 = 0:1 => AVCC with ext capacitor at AREF pin
; ADC Left Adjust Result: ADLAR = 1 => On (8 bits precision reading ADCH only)
; Analog Channel and Gain Selection Bits: MUX4:MUX3:MUX2:MUX1:MUX0
;   1) ImpedanceMeasure  = 6
;   2) OffsetCalibration = 7
;
; * ADC Multiplexer Selection Register:
;     |  REFS1 |  REFS0 |  ADLAR |  MUX4  |  MUX3  |  MUX2  |  MUX1  |  MUX0  |
;     |    0   |    1   |    1   |    0   |    0   |    x   |    x   |    x   |
;
; ADC enable: ADEN = 1 => Enabled
; ADC Auto Trigger Mode: ADATE = 0 => Disabled
; ADC Interrupt Enable: ADIE = 1 => Enabled
; ADC Prescaler Select Bits: ADPS2:ADPS1:ADPS0 = 1:0:1 => fCk_ADC = fCk/32
;
; * ADC Control and Status Register A:
;     |  ADEN  |  ADSC  |  ADATE |  ADIF  |  ADIE  |  ADPS2 |  ADPS1 |  ADPS0 |
;     |    1   |    0   |    0   |    0   |    1   |    1   |    0   |    1   |
;

.equ ADC_AREF_LEFT_ADJUST_CONFIG = (1<<REFS0) | (1<<ADLAR)
.equ ADC_ENABLE_AUTO_INT_PRESC   = (1<<ADEN)  | (1<<ADIE) | \
                                   (1<<ADPS2) | (1<<ADPS0)
.equ ADC_DISABLE            = 0
.equ ADC_PERIODS_TO_SAMPLE  = 9
.equ ADC_SAMPLES_PER_PERIOD = 37 ; Ya que fADC = 37,037 kHz (sampling freq)
.equ ADC_SAMPLES_TABLE_LEN  = ADC_PERIODS_TO_SAMPLE * ADC_SAMPLES_PER_PERIOD

; Enumerativo para la entrada a medir
.equ ADC_IMPEDANCE_MEASURE  = 6
.equ ADC_OFFSET_CALIBRATION = 7

;--------------------- Configuración de rangos de medición --------------------;
; Valores del multiplexor MUX2
.equ MUX2_x30nA  = 0
.equ MUX2_x80nA  = 1
.equ MUX2_x120nA = 2
.equ MUX2_x200nA = 3

; Enumerativo para los rangos de medición
.equ MEAS_RANGE_1 = 0
.equ MEAS_RANGE_2 = 1
.equ MEAS_RANGE_3 = 2
.equ MEAS_RANGE_4 = 3
;---------------------------- Registros especiales ----------------------------;
.def tmp   = R16        ; Temporario, siempre se podrá pisar sin salvarlo
.def param = R17        ; Parámetro para rutinas
.def iter  = R18        ; Iterador, múltiple uso, salvar al pisarlo
.def iter2 = R19        ; Iterador, múltiple uso, salvar al pisarlo

; XXX XXX XXX XXX XXX XXX -- NOTE -- XXX XXX XXX XXX XXX XXX
; Registros siempre en uso por interrupciones, no usar para otra cosa durante
; las mediciones! --> R20, X (R27:R26), R25:R24, Y (R29:R28)
.def tbl_i  = R20 ; Iterador de tabla en RAM, en uso durante mediciones!
.def tbl_jl = R24 ; Iterador de 16-bits (parte baja), en uso durante mediciones!
.def tbl_jh = R25 ; Iterador de 16-bits (parte alta), en uso durante mediciones!


;|//////////////////////////////////////|\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\|;
;|//////////////////////| Direcciones reservadas en RAM |\\\\\\\\\\\\\\\\\\\\\|;
;|//////////////////////////////////////|\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\|;
.dseg
.org SRAM_START

; Tabla: seno escalado, listo para actualizar el PWM
PWM_SINE_RAM_TABLE:
    .byte PWM_SINE_TABLE_LEN

; Tabla: entrada del ADC muestreada durante ADC_PERIODS_TO_SAMPLE períodos
ADC_SAMPLES_RAM_TABLE:
    .byte ADC_SAMPLES_TABLE_LEN

; Tabla: máximos de cada período, luego se ordenará para obtener la mediana
ADC_MAXS_RAM_TABLE:
    .byte ADC_PERIODS_TO_SAMPLE

; Tabla: mínimos de cada período, luego se ordenará para obtener la mediana
ADC_MINS_RAM_TABLE:
    .byte ADC_PERIODS_TO_SAMPLE

; Conversión de BCD a ASCII, en esta posición queda el resultado en ASCII
BCD_TO_ASCII_CONVERT_RAM:
    .byte 5*16


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

; Interrupción de conversión completa del ADC
.org ADCCaddr
    jmp     ADC_SAMPLE_STORE_TO_RAM_ISR

; Interrupción de botón de ESC (INT2)
.org INT2addr
    jmp     INT2_ESC_BUTTON_ISR

; Final del vector de interrupciones
.org INT_VECTORS_SIZE


;|//////////////////////////////////////|\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\|;
;|/////////////////////////////| Datos en flash |\\\\\\\\\\\\\\\\\\\\\\\\\\\\\|;
;|//////////////////////////////////////|\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\|;
PWM_SINE_FLASH_TABLE:
    .db 0x00, 0x0D, 0x19, 0x26, 0x32, 0x3D, 0x48, 0x52, 0x5B, 0x64, 0x6B, 0x72
    .db 0x77, 0x7B, 0x7D, 0x7F, 0x7F, 0x7E, 0x7B, 0x78, 0x73, 0x6D, 0x66, 0x5E
    .db 0x55, 0x4B, 0x40, 0x35, 0x29, 0x1C, 0x10, 0x03, 0xF6, 0xEA, 0xDD, 0xD1
    .db 0xC6, 0xBB, 0xB0, 0xA7, 0x9E, 0x97, 0x90, 0x8B, 0x86, 0x83, 0x81, 0x81
    .db 0x82, 0x84, 0x87, 0x8C, 0x91, 0x98, 0xA0, 0xA9, 0xB3, 0xBD, 0xC8, 0xD4
    .db 0xE0, 0xED

; === Multiplexor MUX2 para cada rango de medición ===
MEAS_RANGE_FLASH_SIN_MUX2_VALUES:
    .db MUX2_x200nA, MUX2_x120nA, MUX2_x80nA, MUX2_x30nA

; === Valor de amplitud para cada rango de medición ===
; 128 --> 100,0 % --> 200,0 nA de corriente pico
;  84 -->  65,6 % -->  52,5 nA de corriente pico
;  92 -->  71,9 % -->  21,6 nA de corriente pico
;  30 -->  23,4 % -->   7,0 nA de corriente pico
MEAS_RANGE_FLASH_SINAMPS:
    .db 128, 128, 128, 128

; === Valores de piso para cada rango de medición, en kilo ohm (16 bit!) ===
MEAS_RANGE_FLASH_FLOOR_VALUES:
    .dw 0, 143, 243, 335 ; Unidad: kohm

; === Valores del parámetro p inicial para cada rango de medición (16 bit!) ===
MEAS_RANGE_FLASH_P_FACTOR_DEFAULTS:
    .dw 421, 649, 901, 2607

; === Valores de continua de corrección para cada rango de medición ===
MEAS_RANGE_FLASH_CONTINUE_MUX2_VALUES:
    .db MUX2_x30nA, MUX2_x80nA, MUX2_x120nA, MUX2_x200nA

; === Valor inicial de calibración del PWM de Offset ===
PWM_OFFSET_FLASH_CALIB_VALUE:
    .db 210, 218, 218, 223
