function biancci(N,CW)

DIFS = 34E-6;   % DIFS [s]
SIFS = 16E-6;   % SIFS [s]
Te = 9E-6;      % Slot time [s]

% Packet sizes [bits]
L_rts = 160;
L_cts = 112; 
L_data = 12000 * 64;
L_ack = 112;


tx_rate = 63148000; % Rate for 1 channel
% tx_rate = 117490000; % Rate for 2 channels
% tx_rate =169100000; % Rate for 4 channels

Ts = (L_rts + L_cts + L_data + L_ack)/tx_rate + DIFS + 3*SIFS + Te;
Tc = L_rts/tx_rate + SIFS + DIFS + L_cts/tx_rate + Te;   % Collision time. It should be  L_rts/tx_rate + SIFS + L_rts/tx_rate + DIFS

tau=2/(CW+1);

p = 1-(1-tau)^(N-1);

pe=(1-tau)^N;
ps = N*tau*(1-tau)^(N-1);
pc=1-pe-ps;

disp('Probabilities: ')
disp([' - pe = ' num2str(pe)])
disp([' - ps = ' num2str(ps)])
disp([' - pc = ' num2str(pc)])
disp([' - p = ' num2str(p)])

S = L_data * ps /(pe*Te+ps*Ts+pc*Tc);
disp('')
disp('Throughput: ')
disp([' - S = ' num2str((S*1e-6)/N) ' Mbps'])

disp([num2str(p*100) '%, ' num2str(S*1e-6)])

end