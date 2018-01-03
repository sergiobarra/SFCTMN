% Proportional fairness of AM vs PU
% - Select for each N value, those scenarios when proportional fairness is non -inf in both PU and AM
clc
close all

n = [2 5 10 20 30 40 50];


pf_am = [16.7334 41.017 80.5056 156.3378723 230.378913 303.1697727 375.5863636];    % average pf of AM 
pf_pu = [16.3062 40.2514 79.5312 155.2370213 229.6095455 302.28 374.4211628];       % average pf of PU

figure
plot(n, pf_am', '-*')
hold on
plot(n, pf_pu', '-*')
xlabel('N')
ylabel('Average Prop. Fairness')
grid on
legend('AM', 'PU')