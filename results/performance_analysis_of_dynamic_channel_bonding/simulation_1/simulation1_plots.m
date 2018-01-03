clear
close all
clc

h = waitbar(0,'Wait, man. Life is nice and easy :)');
steps = 1000;
for step = 1:steps
    % computations take place here
    waitbar(step / steps)
end
close(h)

% 07 Nov 2017: 50 scenarios per N value

%% SEVERAL POLICIES EXPERIMENTS FOR N = 2, 5, 10, 20, 30, 40, 50
n = [2 5 10 20 30 40 50];


% Only primary
s_op = [102.126	92.3272	84.2564	68.7434	60.8242	53.1648 46.6302];
s_std_op = [0.10303556	11.05117097	9.778678338	7.024517301	3.824952495	3.694254911 2.868371856];
% f_op = [16.02	39.7294	75.687	68.7434	228.2332	300.9008];
% f_op_normalized = f_op ./  n;
jfi_op = [0.4999945	0.48054344	0.45964328	0.40647374	0.38461482	0.35779984 0.34117934] .* 2;
s_min_op = [101.78688	77.113344	43.742208	7.39584	2.2848	0.923904 0.766];
bw_used_op = [19.31	17.5182	15.9766	13.0326	11.5318	10.0826	8.8424];

% Static channel bonding
s_scb = [269.5542	167.5852	121.5764	74.8354	53.0502	44.0188 39.8524];
s_std_scb = [125.6758215	66.16588952	32.49805198	14.91005238	7.649539266	6.28372132 6.076116362];
% f_scb = [16.6206	34.8184	38.0304	74.8354	8.186	0 0];  % 0 means that no WLAN could not transmit any packet
% f_scb_normalized = f_scb ./  n;
jfi_scb = [0.44119138	0.3511289	0.28197234	0.21853142	0.19123118	0.17319004 0.1587476] .* 2;
s_min_scb = [184.320768	33.083136	1.161984	0.003072	0.001536	0 0];
bw_used_scb = [56.1854	33.4376	24.3942	14.7556	10.3174	8.496	7.6744];

% Always max
s_am = [281.9558	195.0618	149.034	99.1474	77.478	64.6254 55.213]; 
s_std_am = [116.3289517	57.12014187	26.35651288	13.16684702	6.469925401	5.198296114 3.774114979];
% f_am = [16.7334	41.017	80.5056	99.1474	216.6374	284.972];
% f_am_normalized = f_am ./  n;
jfi_am = [0.44059928	0.40359134	0.36076892	0.33670238	0.32699678	0.30897308 0.3033923] .* 2;
s_min_am = [190.749696	96.014592	39.798528	6.615552	2.040576	1.491456 0.9204];
bw_used_am = [58.5028	38.4684	29.2692	19.0924	14.8304	12.31604651	10.53615385];

% Prob. Uniform
s_pu = [147.0052	119.468	101.3368	77.1152	65.5716	56.602 49.1602];
s_std_pu = [27.19303289	18.80538655	11.24697718	7.781346675	3.908783599	3.599004965 2.822500332];
% f_pu = [16.3062	40.2514	79.5312	77.1152	211.119	277.979]; 
% f_pu_normalized = f_pu ./  n;
jfi_pu = [0.48575976	0.46466352	0.44395944	0.39715058	0.37835122	0.35048534 0.3358469] .* 2;
s_min_pu = [126.780672	84.705024	47.857152	8.379648	2.50752	1.291776091 0.7714];
bw_used_pu = [28.5474	22.8832	19.3632	14.6812	12.4666	10.7556	9.3412];

figure
subplot(1,2,1)
hold on
plot(n, s_op, '-*')
plot(n, s_scb, '-*')
plot(n, s_am, '-*')
plot(n, s_pu, '-*')
grid on
xlabel('N')
ylabel('Average throughput per WLAN [Mbps]')
% xticks(1:length(n))
% xticklabels({'2','5','10', '20', '30', '40', '50', '60'})
legend('OP', 'SCB', 'AM', 'PU')

subplot(1,2,2)
hold on
plot(n, s_min_op, '-*')
plot(n, s_min_scb, '-*')
plot(n, s_min_am, '-*')
plot(n, s_min_pu, '-*')
grid on
xlabel('N')
ylabel('Av. MIN. Throughput [Mbps]')
% xticks(1:length(n))
% xticklabels({'2','5','10', '20', '30', '40', '50', '60'})
legend('OP', 'SCB', 'AM', 'PU')

figure
hold on
plot(n, s_op, '-*')
plot(n, s_scb, '-*')
plot(n, s_am, '-*')
plot(n, s_pu, '-*')
grid on
xlabel('N')
ylabel('Average throughput per WLAN [Mbps]')
legend('OP', 'SCB', 'AM', 'PU')

% figure
% hold on
% plot(n, f_op_normalized, '-*')
% plot(n, f_scb_normalized, '-*')
% plot(n, f_am_normalized, '-*')
% plot(n, f_pu_normalized, '-*')
% grid on
% xlabel('N')
% ylabel('Normalized proportional throughput')
% legend('Only-primary', 'Static CB', 'Always-max', 'Prob. uniform')

figure
hold on
plot(n, jfi_op, '-*')
plot(n, jfi_scb, '-*')
plot(n, jfi_am, '-*')
plot(n, jfi_pu, '-*')
grid on
xlabel('N')
ylabel('Jains fairness index')
% xticks(1:length(n))
% xticklabels({'2','5','10', '20', '30', '40', '50', '60'})
legend('OP', 'SCB', 'AM', 'PU')

figure 
subplot(2,2,1)
errorbar(n,s_op,s_std_op)
xlabel('N')
ylabel('Av. throughput OP')
grid on
subplot(2,2,2)
errorbar(n,s_scb,s_std_scb)
xlabel('N')
ylabel('Av. throughput SCB')
grid on
subplot(2,2,3)
errorbar(n,s_am,s_std_am)
xlabel('N')
ylabel('Av. throughput AM')
grid on
subplot(2,2,4)
errorbar(n,s_pu,s_std_pu)
xlabel('N')
ylabel('Av. throughput PU')
grid on

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

figure
hold on
plot(n, bw_used_op .* n, '-*')
plot(n, bw_used_scb .* n, '-*')
plot(n, bw_used_am .* n, '-*')
plot(n, bw_used_pu .* n, '-*')
grid on
xlabel('N')
ylabel('Total bandiwdth used [MHz]')
legend('OP', 'SCB', 'AM', 'PU')


figure
hold on
plot(n, bw_used_op, '-*')
plot(n, bw_used_scb, '-*')
plot(n, bw_used_am, '-*')
plot(n, bw_used_pu, '-*')
grid on
xlabel('N')
ylabel('Av. bandiwdth used [MHz]')
legend('OP', 'SCB', 'AM', 'PU')


area = 100 * 100;   % Area [m^2]
total_bw = 8 * 20;  % System's bandiwdth [MHz]


a_cs = 5384.6;

figure
hold on
plot(n, bw_used_op .* n * a_cs/ (area * total_bw), '-*')
plot(n, bw_used_scb .* n * a_cs / (area * total_bw), '-*')
plot(n, bw_used_am .* n * a_cs/ (area * total_bw), '-*')
plot(n, bw_used_pu .* n * a_cs/ (area * total_bw), '-*')
grid on
xlabel('M')
ylabel('E[\rho]')
legend('OP', 'SCB', 'AM', 'PU')
