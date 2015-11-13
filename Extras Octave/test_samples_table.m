close all;
clear all;
clc;

pinky  = [250, 160, 180]/255;
blue   = [ 50,  50, 205]/255;
red    = [205,  50,  50]/255;

%|//////////////////////////////////////|\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\|%
%|/////////////////////////////| Configuraciones |\\\\\\\\\\\\\\\\\\\\\\\\\\\\|%
%|//////////////////////////////////////|\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\|%
N_PERIODS_TO_SAMPLE = 9;
SAMPLES_PER_PERIOD = 28;
SAMPLES_TABLE_LEN = N_PERIODS_TO_SAMPLE * SAMPLES_PER_PERIOD;
b = 8;           # bits de trabajo

f = 1e3;         # frecuencia de la onda: 1 kHz
T = 1/f;         # período de la onda
A = 100;         # amplitud de la onda
Nl = 5;          # nivel de ruido, valor pico
off = 128;       # nivel de offset

Ts = T/SAMPLES_PER_PERIOD; # período de muestreo
fs = 1/Ts;                 # frecuencia de muestreo


%||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||%
%|||||||||||||||||||||||||||||||| Procesamiento |||||||||||||||||||||||||||||||%
%||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||%

%------------------------------------ Ideal -----------------------------------%
t0 = 0:Ts/2:N_PERIODS_TO_SAMPLE*T;
y0 = off + A*sin(2*pi*f*t0);

%---------------------------------- Muestras ----------------------------------%
t = 0:Ts:N_PERIODS_TO_SAMPLE*T-Ts;
n = numel(t);
y = round(off+ A*sin(2*pi*f*t) + 2*Nl*rand(1, n)-Nl);


%|//////////////////////////////////////|\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\|%
%|/////////////////////////////////| Gráfico |\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\|%
%|//////////////////////////////////////|\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\|%
plot(t0, y0, 'linewidth', 1.5, 'color', pinky, '-;Ideal;');
hold on;
plot(t, y, 'linewidth', 1.5, 'color', red, '*;Muestras con ruido;');
grid minor;

%|//////////////////////////////////////|\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\|%
%|/////////////////////////////| Salida de tabla |\\\\\\\\\\\\\\\\\\\\\\\\\\\\|%
%|//////////////////////////////////////|\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\|%
c = 12; # cantidad de valores por línea
printf('%d valores (%d por línea):\n', n, c);
for k = 1:n
    if (rem(k-1, c) == 0)
        printf('    .db ')
    endif

    x = y(k);
    if (x < 0)
        x = bitcmp(-x, b) + 1; # complemento a 2 en 8 bits
    endif
    printf("0x%02X", x)

    if (rem(k-1, c) == c-1 || k == n)
        printf('\n')
    else
        printf(', ')
    endif
endfor
printf('\n');
