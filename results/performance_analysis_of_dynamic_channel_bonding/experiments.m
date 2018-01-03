clear
close all
clc

%% ONLY-MAX EXPERIMENT

s_10 = [82.21 86.02 68.51 83.69 90.93 83.07];

f_10 = [78.57 77 79 76];

s_30 = [33.71 33.41 33.35 34.15 33.38 33.33];

f_30 =[224.43 224.65 224.60 223.63];

s_50 = [21.71 21.57 21.46 21.97 21.64 21.42];

f_50 = [365 363 364 366];

figure
subplot(1,2,1);
ylabel('Average throughput [Mbps]')
boxplot([s_10',s_30',s_50'],'Notch','on','Labels',{'N = 10','N = 30', 'N = 50'})
grid on

subplot(1,2,2);
ylabel('Average fairness')
boxplot([f_10',f_30',f_50'],'Notch','on','Labels',{'N = 10','N = 30', 'N = 50'})
grid on

%% SEVERAL POLICIES EXPERIMENTS FOR N = 2, 10, 30

s_op = [105.125 70.5 32.5995 21.5855 15.457];
s_std_op = [19.82 9.55 1.83 0.237 0.1779];
f_op = [19.82 78.081 224.2395 365.2685 537.64]; 
f_std_op = [0.2078 0.675 0.931 0.6141 0.67];
f_op_normalized = f_op ./  [2 10 30 50 75];

s_scb = [197.3015 62.1865 24.93 16.524 12.4155];
s_std_scb = [87.79 11.6 4.069 1.3287 0.6345];    
f_scb = [16.4795 0 0 0 0];  % 0 means that at least one WLAN could not transmit any packet
f_std_scb = [0.38172 0 0 0 0];
f_scb_normalized = f_scb ./  [2 10 30 50 75];

s_am = [202.67 83.0565 33.5015 21.649 15.56];
s_std_am = [92.31 10.479 0.4821 0.243 0.24];
f_am = [16.4775 78.731 224.5815 365.4285 537.334];
f_std_am = [0.409 0.7257 0.47569 0.661881 0.798];
f_am_normalized = f_am ./  [2 10 30 50 75];

s_pu = [143.548 76.4135 33.256 21.59 15.51];
s_std_pu = [28.31 8.93 1.152 0.399 0.13];
f_pu = [16.2925 78.365 224.5585 365.4435 537.42]; 
f_std_pu = [0.18 0.63 0.68645 0.7158 1.346];
f_pu_normalized = f_pu ./  [2 10 30 50 75];

figure
subplot(1,2,1)
hold on
plot(s_op, '-*')
plot(s_scb, '-*')
plot(s_am, '-*')
plot(s_pu, '-*')
grid on
ylabel('Average throughput per WLAN [Mbps]')
xticks(1:5)
xticklabels({'N = 2','N = 10','N = 30', 'N = 50', 'N = 75'})
legend('Only-primary', 'Static CB', 'Always-max', 'Prob. uniform')

subplot(1,2,2)
hold on
plot(f_op_normalized, '-*')
plot(f_scb_normalized, '-*')
plot(f_am_normalized, '-*')
plot(f_pu_normalized, '-*')
grid on
ylabel('Normalized proportional fairness')
xticks(1:5)
xticklabels({'N = 2','N = 10','N = 30', 'N = 50', 'N = 75'})
legend('Only-primary', 'Static CB', 'Always-max', 'Prob. uniform')

% figure
% hold on
% errorbar(1:3,s_op,s_std_op)
% errorbar(1:3,s_scb,s_std_scb)
% errorbar(1:3,s_am,s_std_am)
% errorbar(1:3,s_pu,s_std_pu)
% grid on
% ylabel('Average throughput per WLAN [Mbps]')
% xticks(1:4)
% xticklabels({'N = 2','N = 10','N = 30'})
