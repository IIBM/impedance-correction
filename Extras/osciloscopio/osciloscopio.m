close all;
clear all;
clc;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Colores y configuraciones globales %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
green  = [ 10, 140,  10]/255;

lwp = 1;        % Grosor de primario de línea para gráficos
msp = 4;        % Tamaño primario de los marcadores para gráficos
to_milli = 1e3; % Paso a prefijo mili
to_micro = 1e6; % Paso a prefijo micro



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Lectura de archivos de mediciones %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
lcrop = 1600; % Valor de recorte a izquierda
rcrop = 1800; % Valor de recorte a derecha
file_content = dlmread('WaveData2240.csv', ',', 3, 0);
signal = file_content(lcrop:end-rcrop,:)*diag([to_milli to_milli]);
signal = downsample(signal, 2);



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Gráficos y cálculos de las mediciones %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figure(1);
    hold on;
    plot(signal(:,1), signal(:,2), 'linewidth', lwp, 'color', green);
    grid minor;
    xlabel('$t\ [\SI{}{\milli\second}]$');
    ylabel('$V\ [\SI{}{\milli\volt}]$');



%%%%%%%%%%%%%%%%%%%
%%% Impresiones %%%
%%%%%%%%%%%%%%%%%%%
print(1, '-dtikz', '-S700,300', 'osciloscopio');

system ('./generador.sh');
close all;
