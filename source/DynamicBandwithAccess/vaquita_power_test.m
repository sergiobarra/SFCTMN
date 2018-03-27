close all
clear

tx_power = [10; 15; 20];
tx_gain = 0;
rx_gain = 0;
wavelength = 0.124913524; % [m]
distance = 0:1:1500;    % [m]
cca = -82;  % [dBm]

pw_received = zeros(length(distance),3);
pw_received(:,1) = tx_power(1) + tx_gain + rx_gain + 20 * log10(wavelength./(4*pi*distance)); % [dBm]
pw_received(:,2) = tx_power(2) + tx_gain + rx_gain + 20 * log10(wavelength./(4*pi*distance));
pw_received(:,3) = tx_power(3) + tx_gain + rx_gain + 20 * log10(wavelength./(4*pi*distance));

plot(distance, pw_received(:,1));
hold on;
plot(distance, pw_received(:,2));
plot(distance, pw_received(:,3));
plot(distance, ones(1,length(distance)) * cca, '-.');
grid on;

title('Free Space Path Loss');
xlabel('d [m]');
ylabel('P_{RX} [dBm]');
legend('P_{TX} = 10 dBm', 'P_{TX} = 15 dBm' ,'P_{TX} = 20 dBm', 'CCA level')