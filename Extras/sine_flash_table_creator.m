close all;
clear all;
clc;

pinky  = [250, 160, 180]/255;
blue   = [ 50,  50, 205]/255;
red    = [205,  50,  50]/255;

%|//////////////////////////////////////|\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\|%
%|/////////////////////////////| Configuraciones |\\\\\\\\\\\\\\\\\\\\\\\\\\\\|%
%|//////////////////////////////////////|\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\|%
fCK = 18.432e6;  # frecuencia de clock: 18,432 MHz
b = 8;           # bits del timer del PWM: 8
fs = fCK/(2^b);  # frecuencia de muestreo: una muestra por período de PWM
Ts = 1/fs;       # período de muestreo

f = 1e3;         # frecuencia de la onda: 1 kHz
T = 1/f;         # período de la onda
A = 2^(b-1)-1;   # amplitud de la onda, máxima excursión en 'b' bits


%||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||%
%|||||||||||||||||||||||||||||||| Procesamiento |||||||||||||||||||||||||||||||%
%||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||%

%------------------------------------ Ideal -----------------------------------%
t0 = 0:Ts/2:T;
y0 = A*sin(2*pi*f*(t0-Ts/2));

%---------------------------------- Muestras ----------------------------------%
t = 0:Ts:T-Ts;
y = round(A*sin(2*pi*f*t));
n = numel(t);

%-------------------------------- Onda generada -------------------------------%
t2 = zeros(2*n, 1);
y2 = zeros(2*n, 1);
for k = 1:2*n
    if (rem(k, 2) == 1) 
        t2(k) = t((k+1)/2);
        y2(k) = y((k+1)/2);
    else
        t2(k) = t(k/2)+Ts;
        y2(k) = y(k/2);
    endif 
endfor


%|//////////////////////////////////////|\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\|%
%|/////////////////////////////////| Gráfico |\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\|%
%|//////////////////////////////////////|\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\|%
plot(t0, y0, 'linewidth', 1.5, 'color', pinky, '-;Ideal;');
hold on;
plot(t, y, 'linewidth', 1.5, 'color', red, '*;Muestras;');
plot(t2, y2, 'linewidth', 1.5, 'color', 'black', '-;Onda generada;');
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
