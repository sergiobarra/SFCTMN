clc
close all
clear

alfa = 0.44;    % [dBm/m]
frequency_MHz = 5000;
distance_m = 40:0.1:50;
PL = path_loss_free_space(distance_m, frequency_MHz) + alfa * distance_m;


plot(distance_m, PL);
ylabel('PL [dB]')
xlabel('distance [m]')
grid on