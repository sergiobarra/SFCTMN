clc
close all

%% Exponential distribution
plot_exponential_distr = 0;
if plot_exponential_distr == 1
    t = 0:0.1:6;
    q = 1;
    figure
    plot(t,q*exp(-q*t));
    hold on
    q = 0.5;
    plot(t,q*exp(-q*t)); 
    hold on
    q = 2;
    plot(t,q*exp(-q*t));
    title('Exponential distribution PDF')
    legend('q = 1', 'q = 1/2', 'q = 2')
    ylabel('f(t)')
    xlabel('t')

    figure
    q = 1;
    plot(t,1-exp(-q*t));
    hold on
    q = 0.5;
    plot(t,1-exp(-q*t));
    hold on
    q = 2;
    plot(t,1-exp(-q*t));
    title('Exponential distribution CDF')
    legend('q = 1', 'q = 1/2', 'q = 2')
    ylabel('P(T<t)')
    xlabel('t')
end


%% Proportional Fairness
M = 2;
U = 3;
S = [3 3 3; 3 3 3];
prop_fair = 0;
for i = 1:M
    for j = 1:U
        prop_fair = prop_fair + log(S(i,j));
    end
end
prop_fair
