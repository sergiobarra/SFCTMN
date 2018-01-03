clc
clear
close all

%% Configuration
% CCA = -82 dBm
% P_tx = -15 dBm
% CE = 20 dB (except for no SINR case, where CE = 50 dB)
% Noise = -100 dBm
% CW = 16
% Single-channel
% Free-space at 5 GHz
% d_STA_AP = 1 m
% d_AP_AP = 50, 250, 450, 600 m
% Same and constant data rate

%% SFCTMN
s_50 = [37.9963   37.9963   37.9963];       % Full overlapping
s_250 = [112.1278    1.1159  112.1278];     % Neighbor overlapping
s_450 = [113.2326   57.3679  113.2326];     % Potential overlapping (SINR accomplished)
s_450_noSINR = [113.2326    1.6885  113.2326];     % Potential overlapping: SINR not accomplished in B - CE = 50 dB
s_600 = [113.2326  113.2326  113.2326];     % No overlapping

%% KOMONDOR

s_50_kom = [42.91 42.89 42.84];             % Full overlapping
s_250_kom = [112.20 1.14 112.20];           % Neighbor overlapping
s_450_kom = [113.23 85.98 113.23];          % Potential overlapping (SINR accomplished)
s_450_noSINR_kom = [113.23 0.00 113.23];  % Potential overlapping: SINR not accomplished in B - CE = 50 dB (99.998 % packet lost)
s_600_kom = [113.2241 113.2249 113.2258];                % No overlapping

% Missing WLANs A and C points regarding Komondor
figure
bar([s_50; s_250; s_450; s_450_noSINR; s_600])
hold on
delta_x_axis = 0.225;
plot(1-delta_x_axis,s_50_kom(1), 'r*');
plot(1,s_50_kom(2), 'r*');
plot(1+delta_x_axis,s_50_kom(3), 'r*');

plot(2-delta_x_axis,s_250_kom(1), 'r*');
plot(2,s_250_kom(2), 'r*');
plot(2+delta_x_axis,s_250_kom(3), 'r*');

plot(3-delta_x_axis,s_450_kom(1), 'r*');
plot(3,s_450_kom(2), 'r*');
plot(3+delta_x_axis,s_450_kom(3), 'r*');

plot(4-delta_x_axis,s_450_noSINR(1), 'r*');
plot(4,s_450_noSINR(2), 'r*');
plot(4+delta_x_axis,s_450_noSINR(3), 'r*');

plot(5-delta_x_axis,s_600(1), 'r*');
plot(5,s_600(2), 'r*');
plot(5+delta_x_axis,s_600(3), 'r*');
grid on
grid minor

xticks(1:5)
xticklabels({'L1','L2','L3','L3^*','L4'})
xlabel('Overlapping setting')
ylabel('Trhoguhput [Mbps]')
% legend('WLAN A','WLAN B','WLAN C', 'Komondor')

[legend_h,object_h,plot_h,text_strings] = legend('SFN A','SFN B','SFN C', 'Kom A', 'Kom B', 'Kom C')
