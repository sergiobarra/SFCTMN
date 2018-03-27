function  [] = SergioTemporalTest()
clc
close all
T_tx = 5;
CW = 4;
T_obs = 500;
ch_occupied = [0];
% Possible states
ap_states = [1 1];
A_state = 1;
B_state = 1;
time_in_state = [0 0 0; 0 0 0];
BO_countdown = [0 0];
t_tx_finished = [0 0];

for t = 1:T_obs
    disp(['***** t = ' num2str(t) ' *****'])
    disp(['- A_state = ' num2str(A_state)])
    disp(['  * BO_countdown(1) = ' num2str(BO_countdown(1))])
    disp(['  * t_tx_finished(1) = ' num2str(t_tx_finished(1))])
    disp(['- B_state = ' num2str(B_state)])
    disp(['  * BO_countdown(2) = ' num2str(BO_countdown(2))])
    disp(['  * t_tx_finished(2) = ' num2str(t_tx_finished(2))])
    %% AP A
    % BO state
    if ap_states(1) == 1
        
        if ch_occupied(1) == 1; % If channel is occupied
            % do nothing
        else    % If channel is free
            if BO_countdown(1) == 0 % If BO not computed
                BO_countdown(1) = get_backoff(CW);
            else    % If BO computed
                BO_countdown(1) = BO_countdown(1) - 1;
                if BO_countdown(1) == 0
                    % Change to TX state
                    ap_states(1)=2;
                end
            end
        end
        
        
        
        
        time_in_state(1,1) = time_in_state(1,1) + 1;
        if B_state ~= 2
            if BO_countdown(1) == 0
                BO_countdown(1) = get_backoff(CW);
            elseif BO_countdown(1) == 1
                A_state = 2;
                t_tx_finished(1) = T_tx;
            end
            BO_countdown(1) = BO_countdown(1) - 1;
        end
        % TX state
    elseif A_state == 2
        time_in_state(1,2) = time_in_state(1,2) + 1;
        if  t_tx_finished(1) == 1
            A_state = 1;
            BO_countdown(1) = get_backoff(CW);
        end
        t_tx_finished(1) = t_tx_finished(1) - 1;
    else
        error('unkonwn state!')
    end
    
    %% AP B
    % BO state
    if B_state == 1
        time_in_state(2,1) = time_in_state(2,1) + 1;
        if A_state ~= 2
            if BO_countdown(2) == 0
                BO_countdown(2) = get_backoff(CW);
            elseif BO_countdown(2) == 1
                B_state = 2;
                t_tx_finished(2) = T_tx;
            end
            BO_countdown(2) = BO_countdown(2) - 1;
        end
        % TX state
    elseif B_state == 2
        time_in_state(2,2) = time_in_state(2,2) + 1;
        if  t_tx_finished(2) == 1
            B_state = 1;
            BO_countdown(2) = get_backoff(CW);
        end
        t_tx_finished(2) = t_tx_finished(2) - 1;
    else
        error('unkonwn state!')
    end
    
    % Collision case
    if (B_state == 2 || A_state == 2) && (BO_countdown(1) == 0 && BO_countdown(2) == 0)
        disp('YIHAAAAAAAAAAAAAAAAAAA')
        t = t + T_tx;
        time_in_state(1,3) = time_in_state(1,3) + 1;
        time_in_state(2,3) = time_in_state(2,3) + 1;
        B_state = 1;
        A_state = 1;
    end
end

disp('Share time in TX')
disp(['- AP A: ' num2str(100*time_in_state(1,2)/sum(time_in_state(1,:))) '%'])
disp(['- AP B: ' num2str(100*time_in_state(2,2)/sum(time_in_state(2,:))) '%'])
disp('Share time Collision ')
disp(['- AP A: ' num2str(100*time_in_state(1,3)/sum(time_in_state(1,:))) '%'])
disp(['- AP B: ' num2str(100*time_in_state(2,3)/sum(time_in_state(2,:))) '%'])
end

function [t_backoff] = get_backoff(cw)
t_backoff = ceil(rand*cw);
end