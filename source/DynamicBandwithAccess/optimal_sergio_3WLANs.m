
clc
close all
clear

L = 12000;
Nagg = 64;
show_optimal = true;

%% 3 APs
mu = [81.5727 150.8068; 81.5727 150.8068; 81.5727 150.8068];
lambda = 1.*[1.4815e+04; 1.4815e+04; 1.4815e+04];
alfa = 0.5;
disp('--- SYSTEM SETTINGS ---')
disp(['alfa = ' num2str(alfa)])

Q = [-(lambda(3) + alfa * lambda(2) + (1-alfa) * lambda(2) + lambda(1)),...
    lambda(3), alfa * lambda(2), 0, (1-alfa) * lambda(2), lambda(1), 0;...
    mu(3,1), -(mu(3,1) + lambda(2) + lambda(1)), 0, lambda(2), 0, 0, lambda(1);...
    mu(2,1), 0, -(mu(2,1)+lambda(3)), lambda(3), 0, 0, 0;...
    0, mu(2,1), mu(3,1), -(mu(2,1) + mu(3,1)), 0, 0, 0;...
    mu(2,2), 0, 0, 0, -(mu(2,2)), 0, 0;...
    mu(1,1), 0, 0, 0, 0, -(mu(1,1)+lambda(3)), lambda(3);...
    0, mu(1,1), 0, 0, 0, mu(3,1), -(mu(1,1)+mu(3,1))];

disp('TRANSITION RATE MATRIX Q [1/s]')
disp(Q)

p=mrdivide([zeros(1,size(Q,1)) 1],[Q ones(size(Q,1),1)]); % the left null space of Q is equivalent to solve [pi] * Q =  [0 0 ... 0 1]
[answer, dist] = isreversible(Q,0,1e-8); % ALEX check reversibility
disp('Equilibrium distribution (prob. of being in each possible state)');
disp(p)

S_equiprob = [Nagg * L*(mu(1,1)*p(6)+mu(1,1)*p(7));...
    Nagg * L*(mu(2,1)*p(3)+mu(2,1)*p(4)+mu(2,2)*p(5));...
    Nagg * L*(mu(3,1)*p(2)+mu(3,1)*p(4)+mu(3,1)*p(7))]./ 1E6;

disp('Average throughput per AP [Mbps]:');
disp(S_equiprob)

disp('Average total throughput [Mbps]:');
disp(sum(S_equiprob))

disp('****** LET US OPTIMIZE! *******');

optimal_alfa = 0;
optimal_S = 0;
log_optimal_alfa = 0;
log_optimal_S = 0;

for alfa = 0:0.01:1
    
    Q = [-(lambda(3) + alfa * lambda(2) + (1-alfa) * lambda(2) + lambda(1)),...
        lambda(3), alfa * lambda(2), 0, (1-alfa) * lambda(2), lambda(1), 0;...
        mu(3,1), -(mu(3,1) + lambda(2) + lambda(1)), 0, lambda(2), 0, 0, lambda(1);...
        mu(2,1), 0, -(mu(2,1)+lambda(3)), lambda(3), 0, 0, 0;...
        0, mu(2,1), mu(3,1), -(mu(2,1) + mu(3,1)), 0, 0, 0;...
        mu(2,2), 0, 0, 0, -(mu(2,2)), 0, 0;...
        mu(1,1), 0, 0, 0, 0, -(mu(1,1)+lambda(3)), lambda(3);...
        0, mu(1,1), 0, 0, 0, mu(3,1), -(mu(1,1)+mu(3,1))];
    
    p=mrdivide([zeros(1,size(Q,1)) 1],[Q ones(size(Q,1),1)]); % the left null space of Q is equivalent to solve [pi] * Q =  [0 0 ... 0 1]
    
    S = [Nagg * L*(mu(1,1)*p(6)+mu(1,1)*p(7));...
        Nagg * L*(mu(2,1)*p(3)+mu(2,1)*p(4)+mu(2,2)*p(5));...
        Nagg * L*(mu(3,1)*p(2)+mu(3,1)*p(4)+mu(3,1)*p(7))]./ 1E6;
    
    if sum(S) > sum(optimal_S)
        optimal_alfa = alfa;
        optimal_S = S;
        optimal_Q = Q;
        optimal_p = p;
    end
    
end

if show_optimal
    disp('*************************')
    disp('OPTIMAL ESTIMATED RESULTS')
    disp('*************************')
    % disp('TRANSITION RATE MATRIX Q [1/s]')
    % disp(Q)
    disp(['optimal_alfa = ' num2str(optimal_alfa)])
    disp(['Equilibrium distribution (prob. of being in each possible state) ---> Sums ' num2str(sum(p))]);
    disp(p)
    disp('Average throughput per AP [Mbps]:');
    disp(optimal_S)
    disp('Average total throughput [Mbps]:');
    disp(sum(optimal_S))
    disp(['S_equiprob = ' num2str(sum(S_equiprob)) ' (improved in ' ...
        num2str(100*(sum(optimal_S)-sum(S_equiprob))/sum(S_equiprob)) ' %)']);
end


