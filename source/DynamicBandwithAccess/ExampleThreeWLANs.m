function  [S,p]=ExampleThreeWLANs()
    % Function that returns:
    %   S: throughput of each WLAN
    %   p: equilibrium distribution (a.k.a "pi")
    
    clc
    close all
    clear
    
    Nnodes = 1; % [SERGIO] Number of nodes per WLAN?
    pe = 0.0;   % [SERGIO] Packet error probability (a packet is declared incorrect if at least one bit is erroneous)
    CW = 16;    % [SERGIO] Contention window (every node picks an integer backoff value in the range [0,CW-1])
    Nagg = 64;  % [SERGIO] Number of aggregated packets in each transmission
    
    disp('--- EXAMPLE TWO WLANs ---')
    
    SLOT=9E-6;      % [SERGIO] DCF slot time are 9 microseconds
    EB=(CW-1)/2;    % [SERGIO] Backoff average duration [slot]
    tau=1/(EB+1);   % [SERGIO] VARIABLE NOT USED
    
    N(1)=Nnodes;    % [SERGIO] Number of nodes in each WLAN
    N(2)=Nnodes;
    N(3)=Nnodes;
    
    lambda = 1/(EB * SLOT); % [SERGIO] Packet generation rate (there is a packet "entering" every time the BO runs to 0)
    lambda = 1*lambda;
    L = 12000;              % [SERGIO] Packet length [bits]
    M = 1;                  % [SERGIO] ???
    MS = 1;                 % [SERGIO] ???
    
    % Transmission duration
    [Ts1,Tc1] = TxDuration(M, Nagg, 1, L, 1, MS);
    [Ts2,Tc2] = TxDuration(M, Nagg, 2, L, 1, MS);
    [Ts3,Tc3] = TxDuration(M, Nagg, 4, L, 1, MS);
    [Ts4,Tc4] = TxDuration(M, Nagg, 8, L, 1, MS);
    % [SERGIO] Packet departure rate when using 1, 2, 4 or 8 channels?
    mu(1)=1/(Ts1);
    mu(2)=1/(Ts2);
    mu(3)=1/(Ts3);
    mu(4)=1/(Ts4);
    
    % [SERGIO] Number of channels in the medium
    n_chan = 4;% optional it can be omitted (default is 19) IT CAN SPEED UP COMPUTATION IS CHANNELS ARE NOT USED
    
    disp('lambda [1/s]: ');
    disp(lambda);
    disp('mu [1/s]: ');
    for i=1:4
        disp(['- Nc = ' num2str(i) ': ' num2str(mu(i))]);
    end
    
    % [SERGIO] Primary channel. WLAN, if TXing, would user at least primary channel.
    wlan(1).primary = 1;
    wlan(2).primary = 2;
    wlan(3).primary = 4;
    % [SERGIO] WLAN channel range. Available channels.
    wlan(1).range = [1 1];
    wlan(2).range = [1 4];
    wlan(3).range = [3 4];
    
    onlymax = true; % ALEX false to allow also intermediate widths
    selfloop = false; % ALEX reversible case
    
    for i=1:numel(wlan)
        if (max(wlan(i).range) - min(wlan(i).range))>n_chan
            error(['Range of WLAN ' num2str(i) ' is greater than the number of channels (' num2str(n_chan) ')']);
        else
            if any(wlan(i).primary == [wlan(i).range(1):wlan(i).range(2)])
                wlan(i).lambda = N(i)*lambda;
                wlan(i).mu = mu;
            else
                error(['Error! Primary channel ' num2str(wlan(i).primary) ' is not in range of WLAN ' num2str(i)]);
            end
        end
    end    
    
    % [SERGIO] What kind of matrix is this? Rate transition matrix? Why elements i = j are negative?
    [m,wlan,glob] = create_matrix_dbca(wlan,n_chan,onlymax,selfloop); %ALEX tochange is a matrix with the rates of only the states going right, you can use it to change to other values and then you need to put this in m manually
    disp('---- STATES ----')
    for i=1:size(glob.states,1)
        disp(['state ' num2str(i) ':'])
        disp([ wlan(1).states(glob.states(i,1),:);...
            wlan(2).states(glob.states(i,2),:);...
            wlan(3).states(glob.states(i,3),:)])
    end
    disp('--- TRANSITION RATE MATRIX [1/s] ---')
    disp(m)
    disp('----');
        
    save m;
    % Solve Markov Chain
    p=mrdivide([zeros(1,size(m,1)) 1],[m ones(size(m,1),1)]); % the left null space of Q is equivalent to solve [pi] * Q =  [0 0 ... 0 1]
    [answer, dist] = isreversible(m,p,1e-8); % ALEX check reversibility
    disp('Equilibrium distribution (prob. of being in each possible state)');
    disp(p)
    disp(['Reversible Markov chain? ' num2str(answer) ' (error: ' num2str(dist) ')'])
    
    
    %pause
    global_widths = unique([wlan.widths]);
    max_global_width = max(global_widths)+1; % first element is width zero
    prob = zeros(numel(wlan),numel(global_widths)); % element prob(i,j) is prob of wlan i to spend time transmitting on width j
    prob=zeros(numel(wlan),5);
    
    for i=1:size(glob.states,1)
        for wl=1:size(glob.states,2)
            prob(wl,global_widths==wlan(wl).widths(glob.states(i,wl))) = prob(wl,global_widths==wlan(wl).widths(glob.states(i,wl))) + p(i);
        end
    end
    
    %disp('Probabilities');
    
    %disp([[1:51]' p']);
    
    disp('per width probability (row is WLAN, column is width)')
    disp(prob);
    
    for j= 1:numel(global_widths)
        wwww = global_widths(j);
        disp(['Probability (for each WLAN) of transmitting with ' num2str(wwww) ' basic channels is:'])
        disp(prob(:,j)')
        %pause
        
    end
    
    %disp(prob);
    
    for i=1:3
        %disp([i prob(i,:)]);
        %pause
        S_prob(i,:) = (prob(i,2:5).*mu)*L*Nagg./1E6;
        
        S(i) = (1 - pe) * Nagg * L *(mu(1) * prob(i,2) + mu(2) * prob(i,3) + mu(3) * prob(i,4) + mu(4) *prob(i,5)) ./ 1E6;
    end
    
    disp('Throughput per state');
    disp(S_prob);
    
    disp('Throughput');
    disp(S);
    disp(['Total throughput: ' num2str(sum(S))]);
    %keyboard
    return
    
    
end


% ----------------------------------------------------------------------
% ----------------------------------------------------------------------
% ----------------------------------------------------------------------
% ----------------------------------------------------------------------
% ----------------------------------------------------------------------
% ----------------------------------------------------------------------

function [Ts,Tc] = TxDuration(M, Nagg, Nc,L,MU,MS)
    
    %Nsc=52;
    
    switch Nc
        case 1
            Nsc = 52;
            Nbs = 6;
            Ncr = 5/6;
        case 2
            Nsc = 108;
            Nbs = 6;
            Ncr = 3/4;
        case 4
            Nsc = 234;
            Nbs = 4;
            Ncr = 3/4;
        case 8
            Nsc = 468;
            Nbs = 4;
            Ncr = 1/2;
        otherwise
            Nsc = 52*Nc;
            Nbs = 6;
            Ncr = 3/4;
    end
    
    
    SIFS = 16E-6;
    SLOT = 9E-6;
    ASIFS = 2 * SLOT + SIFS;
    
    T_symbol = 4E-6;
    T_PHY = 40E-6 + 4E-6*(M-1);
    
    L_SF = 16;
    L_MH = 288;
    L_MD = 16;
    L_BACK = 256;
    L_TAIL = 18;
    
    L_DBPS = Nbs * Ncr * Nsc;
    L_DBPS_ACK = Nbs * Ncr * 52;
    
    if(Nagg==1)
        Ts = T_PHY + ceil((L_SF+(L_MH+L)+L_TAIL)/(MS*L_DBPS))*T_symbol + MU*(SIFS + T_PHY + ceil(L_BACK / L_DBPS_ACK)*T_symbol);
    else
        Ts = T_PHY + ceil((L_SF+Nagg*(L_MD+L_MH+L)+L_TAIL)/(MS*L_DBPS))*T_symbol + MU*(SIFS + T_PHY + ceil(L_BACK / L_DBPS_ACK)*T_symbol);
    end
    
    Ts = ASIFS+Ts+SLOT;
    
    Tc = Ts;
    
    %disp([Ts]);
    %pause
    
end
