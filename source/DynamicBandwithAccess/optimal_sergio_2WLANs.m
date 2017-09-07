
clc
close all
clear

L = 12000;
Nagg = 64;
show_optimal = true;

%% 2 APs
mu = [81.5727 150.8068; 81.5727 150.8068];
lambda = 1.*[1.4815e+04; 1.4815e+04];
alfa_A1 = 0.5;
alfa_B1 = 0.5;
alfa = [alfa_A1, 1-alfa_A1; alfa_B1, 1-alfa_B1];
disp('--- SYSTEM SETTINGS ---')
disp(['alfa_A1 = ' num2str(alfa_A1) ', alfa_B1 = ' num2str(alfa_B1)])

Q = [-(alfa(2,1) * lambda(2) + alfa(2,2) * lambda(2) + alfa(1,1) * lambda(1)...
    + 0 + alfa(1,2) * lambda(1)), alfa(2,1) * lambda(2), alfa(2,2) * lambda(2),...
    alfa(1,1) * lambda(1), 0, alfa(1,2) * lambda(1);...
    mu(2,1), -(mu(2,1)+lambda(1)), 0, 0, lambda(1), 0;...
    mu(2,2), 0, -(mu(2,2)), 0, 0, 0;...
    mu(1,1), 0, 0, -(mu(1,1)+lambda(2)), lambda(2), 0;...
    0, mu(1,1), 0, mu(2,1), -(mu(1,1)+mu(2,1)), 0;...
    mu(1,2), 0, 0, 0, 0, -(mu(1,2))];

disp('TRANSITION RATE MATRIX Q [1/s]')
disp(Q)

p=mrdivide([zeros(1,size(Q,1)) 1],[Q ones(size(Q,1),1)]); % the left null space of Q is equivalent to solve [pi] * Q =  [0 0 ... 0 1]
[answer, dist] = isreversible(Q,0,1e-8); % ALEX check reversibility
disp('Equilibrium distribution (prob. of being in each possible state)');
disp(p)

S_equiprob = [(Nagg * L*(mu(1,1)*p(4)+mu(1,2)*p(6)+mu(1,1)*p(5)));...
    (Nagg * L*(mu(1,1)*p(2)+mu(1,2)*p(3)+mu(1,1)*p(5)))]./ 1E6;

disp('Average throughput per AP [Mbps]:');
disp(S_equiprob)

disp('Average total throughput [Mbps]:');
disp(sum(S_equiprob))

optimal_alfa = [0; 0];
optimal_S = 0;
k = 100;
J = zeros(k+1,k+1);
kA = 0;
for alfa_A1 = 0:1/k:1
    kB = 0;
    kA = kA + 1;
    for alfa_B1 = 0:1/k:1
        kB = kB + 1;
        Q = [-(alfa_B1 * lambda(2) + (1-alfa_B1) * lambda(2) + alfa_A1 * lambda(1) + 0 + (1-alfa_A1) * lambda(1)),...
            alfa_B1 * lambda(2), (1-alfa_B1) * lambda(2),...
            alfa_A1 * lambda(1), 0, (1 - alfa_A1) * lambda(1);...
            mu(2,1), -(mu(2,1)+lambda(1)), 0, 0, lambda(1), 0;...
            mu(2,2), 0, -(mu(2,2)), 0, 0, 0;...
            mu(1,1), 0, 0, -(mu(1,1)+lambda(2)), lambda(2), 0;...
            0, mu(1,1), 0, mu(2,1), -(mu(1,1)+mu(2,1)), 0;...
            mu(1,2), 0, 0, 0, 0, -(mu(1,2))];
        p = mrdivide([zeros(1,size(Q,1)) 1],[Q ones(size(Q,1),1)]); % the left null space of Q is equivalent to solve [pi] * Q =  [0 0 ... 0 1]
        
        S = [(Nagg * L*(mu(1,1)*p(4)+mu(1,2)*p(6)+mu(1,1)*p(5)));...
            (Nagg * L*(mu(1,1)*p(2)+mu(1,2)*p(3)+mu(1,1)*p(5)))]./ 1E6;

        J(kA, kB) =  sum(S);
        
        if sum(S) > sum(optimal_S)
            optimal_alfa = [alfa_A1; alfa_B1];
            optimal_S = S;
            optimal_Q = Q;
            optimal_p = p;
        end
    end
end

surf(J)
xlabel('\alpha')
ylabel('\beta')
axis([0 100 0 100 min(min(J)) max(max(J))])

zlabel('S (Mbps)')


if show_optimal
    disp('*************************')
    disp('OPTIMAL ESTIMATED RESULTS')
    disp('*************************')
    % disp('TRANSITION RATE MATRIX Q [1/s]')
    % disp(Q)
    disp(['alfa_A1 = ' num2str(optimal_alfa(1)) ', alfa_B1 = ' num2str(optimal_alfa(2))])
    disp(['Equilibrium distribution (prob. of being in each possible state) ---> Sums ' num2str(sum(p))]);
    disp(p)
    disp('Average throughput per AP [Mbps]:');
    disp(optimal_S)
    disp('Average total throughput [Mbps]:');
    disp(sum(optimal_S))
    disp(['S_equiprob = ' num2str(sum(S_equiprob)) ' (improved in ' ...
        num2str(100*(sum(optimal_S)-sum(S_equiprob))/sum(S_equiprob)) ' %)']);
end
