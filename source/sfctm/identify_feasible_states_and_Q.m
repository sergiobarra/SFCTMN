%%% *********************************************************************
%%% * Spatial-Flexible CTMN for WLANs                                   *
%%% * Author: Sergio Barrachina-Munoz (sergio.barrachina@upf.edu)       *
%%% * Copyright (C) 2017-2022, and GNU GPLd, by Sergio Barrachina-Munoz *
%%% * GitHub repository: https://github.com/sergiobarra/SFCTMN          *
%%% * More info on https://www.upf.edu/en/web/sergiobarrachina          *
%%% *********************************************************************

function [ Q, S, S_cell, T_S, T_PSI, S_num_states, mcs_index_cell ] = ...
    identify_feasible_states_and_Q( PSI_cell, Power_AP_PSI_cell, Power_Detection_PSI_cell, ...
    Individual_Power_AP_PSI_cell, num_channels_system, wlans, mcs_indexes, ...
    Interest_Power_PSI_cell, SINR_cell, logs_algorithm_on )
    %IDENTIFY_FEASIBLE_STATES function for finding the feasible state space (S) and transition rate matrix (Q) of a 
    % given WLAN system taking the power sensed in the interest spectrum into consideration. This algorithm is an 
    % extension to allow non-fully overlapping networks of "Faridi, Azadeh, Boris Bellalta, and Alessandro Checco. 
    % "Analysis of dynamic channel bonding in dense networks of WLANs." IEEE Transactions on Mobile Computing 16.8 
    % (2017): 2118-2131. 
    %
    % Input:
    %   - PSI_cell: set of global states in cell array form
    %   - Power_PSI_cell: power sensed by every wlan in every channel in every global state [dBm]
    %   - num_channels_system: number of channels in the system
    %   - wlans: array of structures with wlans info
    %   - dsa_policy: type of DSA-DCB policy. It determines what channel range to pick depending on the sensed power
    %   - logs_on: flag for activating or deactivating logs
    % Output:
    %   - Q: S's CTMC transition rate matrix
    %   - S: 3d matrix representing the feasible states
    %   - S_cell: cell array representing the feasible states
    %   - T_S: logical transition rates matrix in feasible space (just backward and forward transitions identified)
    %   - T_PSI: logical transition rates matrix in global space
    %   - S_num_states: number of feasible states 
    
    load('constants_sfctmn_framework.mat');  % Load constants into workspace
    load('configuration_system.mat');    % Load system configuration
    
    if logs_algorithm_on
        disp(' ');
        disp('--- IDENTIFYING FEASIBLE STATES (S) ---');
        transitions_counter = 0;    % Number of transitions detected by the algorithm
    end
    
    num_global_states = length(PSI_cell);   % Number of global states
    num_wlans = length(wlans);              % Number of WLANs
    T_PSI = zeros(num_global_states, num_global_states);    % Logical transition rates matrix in global space PSI
    T_S = [];                   % Logical transitions matrix in feasible state space S
    i = 1;                      % Index of the last state found by the algorithm
    k = 1;                      % Index of the state currently being used by the algorithm for discovery
    S_cell{1} = PSI_cell{1};    % Set of feasible states. Empty state always belong to S
    Q = []; % S's transition rate matrix
    for psi_ix = 1 : num_global_states
        mcs_index_cell{psi_ix} = zeros(1, num_wlans);
    end
        
    wlans_types = check_wlans_types(wlans);
        
    while k <= length(S_cell)   % While there are known states in S not explored yet
        
        if logs_algorithm_on
            [~, psi_ix] = find_state_in_set(S_cell{k}, PSI_cell);
            disp(['s' num2str(k) ' (s_psi #' num2str(psi_ix) '):']);
            disp(S_cell{k})
        end
        
        for wlan_ix = 1 : num_wlans     % For each WLAN
                       
            % WLAN state in psi (0: unactive, 1: active, 2-3: active with SR)
            wlan_state_in_s =  S_cell{k}(wlan_ix,:);
            if wlan_state_in_s > 0  
                wlan_active_in_s = true;
            else 
                wlan_active_in_s = false;
            end
            
            %%% BACKWARD TRANSITIONS
            %%%   - If wlan is ACTIVE in s ---> set backward transitions to known and unknown states
            if wlan_active_in_s     
                % Check all the possible states                
                for psi_ix = 1 : num_global_states  % For each state in PSI (psi)     
                    % Flag determining if WLANs different from wlan (i.e. wlan_aux) remain the same in state s and psi
                    other_wlans_remain_same = true; 
                    for wlan_aux_ix = 1 : num_wlans     % Foreach WLAN
                        % Condition I) Other WLANs in new state psi (active or not) must have same channel range that in s
                        if wlan_aux_ix ~= wlan_ix   % Different WLAN than wlan                          
                            % Channel range of wlan_aux in state s
                            wlan_aux_state_in_s = S_cell{k}(wlan_aux_ix,:);
                            % Channel range of wlan_aux in state psi
                            wlan_aux_state_in_psi = PSI_cell{psi_ix}(wlan_aux_ix,:);
                            % If wlan_aux different in s than psi
                            if wlan_aux_state_in_s ~= wlan_aux_state_in_psi
                                other_wlans_remain_same = false;
                            end
                        end
                    end
                    % Condition II) WLAN "wlan" must NOT be active in state psi_ix
                    wlan_state_in_psi = PSI_cell{psi_ix}(wlan_ix,:);
                    if wlan_state_in_psi > 0
                        wlan_active_in_psi = true;
                    else 
                        wlan_active_in_psi = false;
                    end
                    % WLAN wlan_ix should be NOT active in state psi_ix, while the rest of wlans should remain the same
                    if other_wlans_remain_same && ~wlan_active_in_psi
                        origin_s_ix = k; % S's index of the backward transition origin state 
                        % S's index of the backward transition destination state (if exists in S)
                        [is_psi_in_s, destination_s_ix] = find_state_in_set(PSI_cell{psi_ix}, S_cell);
                        % PSI's index of the backward transition origin state 
                        [~, origin_psi_ix] = find_state_in_set(S_cell{k}, PSI_cell);
                        % PSI's desitnation index of the backward transition destination state
                        destination_psi_ix = psi_ix;
                        % If destination state NOT known in S, add it 
                        if ~is_psi_in_s                                
                            i = i + 1;                      % Update last found state index
                            S_cell{i} = PSI_cell{psi_ix};   % Add destination state
                            destination_s_ix = i;
                            if logs_algorithm_on
                                disp(['   * New state s' num2str(destination_s_ix)...
                                    ' (s_psi #' num2str(destination_psi_ix) ') added to S']);
                            end
                        end  
                        % Add new transition                        
                        T_S(origin_s_ix, destination_s_ix) = BACKWARD_TRANSITION;
                        % Departure rate of WLAN wlan in current state s                    
                        mcs_index = mcs_indexes{origin_psi_ix}(wlan_ix, 1);
                        mcs_index_cell{origin_psi_ix}(wlan_ix) = mcs_index;  
                        num_ch_wlan_s = 1;  % Number of channels used by WLAN wlan in current state s
                        
                        %%%%%%%%%%%%%%%%%%%%%%%%%% NEW                        
                        % Check if the transmission is successful or not
                        % (in order to limit the tx duration)
                        interest_power = Interest_Power_PSI_cell{origin_psi_ix}(wlan_ix);
                        sinr = SINR_cell{origin_psi_ix}(wlan_ix);
                        if (sinr < CAPTURE_EFFECT) || (interest_power < wlans(wlan_ix).cca)
                            % The transmission duration lasts until the CTS timeout
                            TimeoutFlag = true;
                        else
                            % The entire transmission duration is considered
                            TimeoutFlag = false;
                        end   
%                         disp(['Backward transition from ' num2str(origin_psi_ix) ' to ' num2str(destination_psi_ix)])
%                         TimeoutFlag
%                         interest_power
%                         sinr
                        mu_s = 1 / SUtransmission80211ax(PACKET_LENGTH, NUM_PACKETS_AGGREGATED, ...
                            num_ch_wlan_s * CHANNEL_WIDTH_MHz, SINGLE_USER_SPATIAL_STREAMS, mcs_index, TimeoutFlag);
                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                        
%                         mu_s = 1 / SUtransmission80211ax(PACKET_LENGTH, NUM_PACKETS_AGGREGATED, ...
%                             num_ch_wlan_s * CHANNEL_WIDTH_MHz,...
%                             SINGLE_USER_SPATIAL_STREAMS, mcs_index);
                        % Update Q with the departure rate
                        Q(origin_s_ix, destination_s_ix) = mu_s;
                        % Indicate in T_PSI the type of transition
                        T_PSI(origin_psi_ix, destination_psi_ix) = BACKWARD_TRANSITION;
                        if logs_algorithm_on                            
                            transitions_counter = transitions_counter + 1;                            
                            disp(['   * New backward transition (#' num2str(transitions_counter) ') from s' num2str(origin_s_ix)...
                                ' (s_psi #'  num2str(origin_psi_ix) ') to s' num2str(destination_s_ix)...
                                ' (s_psi #' num2str(destination_psi_ix) ')']);                            
                        end
                        
                    end % End backward transition's condition
                end % End loop global states
                
            %%% FORWARD TRANSITIONS
            %%%  - If wlan is NOT ACTIVE in s ---> find forward transitions to other states if any
            else    
                % Look if there are states in PSI (psi) that that differs from s only by the participation of WLAN wlan_ix
                possible_forward_states = find_possible_forward_states(PSI_cell, ...
                    S_cell, num_global_states, num_wlans, k, wlan_ix, logs_algorithm_on);
                % If there are possible global states to transit to from current state s
                if ~isempty(possible_forward_states) 
                    % State to transit forward to (psi_forward) depends on the DSA policy applied
                    [~, psi_ix] = find_state_in_set(S_cell{k}, PSI_cell);
                    % PSI's index of the backward transition origin state 
                    [~, origin_psi_ix] = find_state_in_set(S_cell{k}, PSI_cell);                    
                    % Obtain the states that are feasible, according to the channel access policy
                    [psi_forward, ~] = find_forward_states( possible_forward_states, ...
                        PSI_cell, Power_AP_PSI_cell, Power_Detection_PSI_cell, ...
                        Individual_Power_AP_PSI_cell, wlans, wlan_ix, origin_psi_ix);    
                    if ~isempty(psi_forward)  % Check if there is a global state to transit from current state s
%                         normal_transmission_flag = false;   % Flag to indicate a normal transmission
%                         sr_transmission_flag = false;       % Flag to indicate an SR transmission
%                         % Check if there are >1 feasible states for a given WLAN (normal and SR modes)
%                         if length(psi_forward) > 1
%                             for psi_forward_aux_ix = 1 : length(psi_forward)   
%                                 state_wlan = PSI_cell{psi_forward(psi_forward_aux_ix)}(wlan_ix);
%                                 if state_wlan == 1
%                                     normal_transmission_flag = true;
%                                     state_normal_transmission = psi_forward(psi_forward_aux_ix);
%                                 elseif state_wlan > 1
%                                     sr_transmission_flag = true;
%                                 end                                                                                                               
%                             end 
%                         end
%                         % If a normal transition exists, only consider its forward transition                        
%                         if normal_transmission_flag 
%                             psi_forward = state_normal_transmission;
%                         % Otherwise, transit to the SR feasible state
%                         elseif (~normal_transmission_flag && sr_transmission_flag) ...
%                                 || (PSI_cell{psi_forward(1)}(wlan_ix) > 1 && length(psi_forward) == 1)                                                      
%                             % Process feasible states in order to discard these that are impossible     
%                             psi_forward = process_psi_forward_sr(psi_forward, ...
%                                 PSI_cell, psi_ix, wlans, wlan_ix, wlans_types);                            
%                         end
                        % Update the CTMN with the feasible forward states and transitions
                        for psi_forward_aux_ix = 1 : length(psi_forward)
                            % S's index of the forward transition origin state 
                            origin_s_ix = k; 
                            % S's index of the forward transition destination state (if exists in S)
                            [is_psi_forward_in_s, destination_s_ix] =...
                                find_state_in_set(PSI_cell{psi_forward(psi_forward_aux_ix)}, S_cell);
                            % PSI's index of the forward transition origin state                         
                            [~, origin_psi_ix] = find_state_in_set(S_cell{k}, PSI_cell);
                            % PSI's desitnation index of the backward transition destination state
                            destination_psi_ix = psi_forward(psi_forward_aux_ix);
                            % If state psi_forward is not in S yet, add it
                            if ~is_psi_forward_in_s
                                i = i + 1;                          % Update last found state index
                                S_cell{i} = PSI_cell{psi_forward(psi_forward_aux_ix)};  % Add state
                                destination_s_ix = i;
                                if logs_algorithm_on
                                    disp(['   * New state s' num2str(destination_s_ix)...
                                        ' (s_psi #' num2str(destination_psi_ix) ') added to S']);
                                end
                            end
                            % Update transitions matrix and Q
                            T_PSI(origin_psi_ix, destination_psi_ix) = FORWARD_TRANSITION;
                            T_S(origin_s_ix, destination_s_ix) = FORWARD_TRANSITION;
                            Q(origin_s_ix, destination_s_ix) = wlans(wlan_ix).lambda;
                            if logs_algorithm_on
                                transitions_counter = transitions_counter + 1;
                                disp(['   * New forward transition (#' num2str(transitions_counter) ') from s' num2str(origin_s_ix)...
                                    ' (s_psi #' num2str(origin_psi_ix) ') to s' num2str(destination_s_ix)...
                                    ' (s_psi #' num2str(destination_psi_ix) ')']);
                            end
                            
                        end % End loop "psi_forward" states
                    end % End if "psi_forward" is empty
                end % End if "possible_forward_states" is empty
                
            end % End if wlan_is_active (backward or forward transisions)
            
        end % End loop for all WLANs 
        
        k = k + 1;  % Update index of the state used for state and transition discovery
        
    end % End iterating for each state
        
    %%% REFACTOR MISSING BACKWARD TRANSITIONS
    %%%   - Check "lonely" SR states 
    if logs_algorithm_on
        disp('%%%%%%%%%%%%%%%%%%%%%')
        disp('Refactor missing Backward transitions ("lonely" SR states):')
    end
    % Iterate for each possible state
    for psi_ix = 1 : num_global_states
        % Determine the wlans that are active in target state "psi_ix"
        active_sr_wlan = [];
        for wlan_ix = 1 : num_wlans            
            if PSI_cell{psi_ix}(wlan_ix) > 0
                active_sr_wlan = [active_sr_wlan wlan_ix];
            end            
        end   
        % If there is a single active WLAN under the SR mode, then check if a backward transition exists for that state
        if size(active_sr_wlan, 2) == 1 && PSI_cell{psi_ix}(active_sr_wlan) > 1  
            not_found = true;   % Set "not_found" to true by default
            psi_ix_aux = 1;     % Index of the "father" state in PSI of "psi_ix" (the state where psi_ix comes from)
            while not_found && psi_ix_aux < num_global_states
                % Check if there is a backward transition between "psi_ix_aux" and "psi_ix"
                if T_PSI(psi_ix_aux, psi_ix) == BACKWARD_TRANSITION   
                    % Compute mu_s for lonely "SR" state to null state
                    
                    %%%%%%%%%%%%%%%%%%%%%%%%%% NEW                        
                    % Check if the transmission is successful or not
                    % (in order to limit the tx duration)
                    interest_power = Interest_Power_PSI_cell{psi_ix_aux}(active_sr_wlan);
                    sinr = SINR_cell{psi_ix_aux}(active_sr_wlan);
                    if (sinr < CAPTURE_EFFECT) || (interest_power < wlans(active_sr_wlan).cca) 
                        % The transmission duration lasts until the CTS timeout
                        TimeoutFlag = true;
                    else
                        % The entire transmission duration is considered
                        TimeoutFlag = false;
                    end   
                    
%                     disp(['Backward transition from ' num2str(psi_ix_aux) ' to ' num2str(psi_ix_aux)])
                    
                    mu_s = 1 / SUtransmission80211ax(PACKET_LENGTH, NUM_PACKETS_AGGREGATED, ...
                        num_ch_wlan_s * CHANNEL_WIDTH_MHz, SINGLE_USER_SPATIAL_STREAMS, mcs_indexes{psi_ix}(active_sr_wlan, 1), TimeoutFlag);
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                     
                    %mu_s = 1 / SUtransmission80211ax(PACKET_LENGTH, NUM_PACKETS_AGGREGATED, num_ch_wlan_s * CHANNEL_WIDTH_MHz,...
                    %    SINGLE_USER_SPATIAL_STREAMS, mcs_index_cell{psi_ix}(active_sr_wlan));   
                    
                    % Find state "psi_ix" in feasible space S
                    [~, origin_s_ix] = find_state_in_set(PSI_cell{psi_ix}, S_cell); 
                    % Update mu_s in the Q matrix
                    Q(origin_s_ix, 1) = mu_s;
                    % Stop "while"
                    not_found = false;
                    if logs_algorithm_on
                        disp(['   - Backward transition detected from ' num2str(psi_ix)])
                        disp(['   - Modifying Q for transition ' num2str(origin_s_ix) ' (PSI_ix = ' num2str(psi_ix) ') to ' num2str(1)]) 
                    end
                end
                psi_ix_aux = psi_ix_aux + 1;
            end
        end  
    end
    
%     %%% REFACTOR MISSING FORWARD TRANSITIONS
%     %%%   - Check unexpected connections for SR states: cases where a backward transition exists, but not a forward one
%     if logs_algorithm_on
%         disp('%%%%%%%%%%%%%%%%%%%%%')
%         disp('Refactor missing Forward transitions (unexpected connections in SR states):')
%     end
%     % Iterate for each possible source state
%     for origin_psi_ix = 1 : num_global_states    
%         % Determine the wlans that are active in target state "origin_psi_ix"
%         active_sr_wlan = [];
%         for wlan_ix = 1 : num_wlans            
%             if PSI_cell{origin_psi_ix}(wlan_ix) > 0
%                 active_sr_wlan = [active_sr_wlan wlan_ix];
%             end            
%         end       
%         % If there are active wlans, check if there are feasible and undetected forward transitions
%         if size(active_sr_wlan, 2) > 0
%             % Iterate for each possible destination state
%             for dest_psi_ix = 1 : num_global_states 
%                 % First condition: there is backward but not forward transition                  
%                 if T_PSI(dest_psi_ix, origin_psi_ix) == BACKWARD_TRANSITION && T_PSI(origin_psi_ix, dest_psi_ix) == 0                   
%                     %  Find the wlan that attempts to access the channel
%                     difference = PSI_cell{dest_psi_ix} - PSI_cell{origin_psi_ix};
%                     wlan_ix_aux = find(difference > 0);  % wlan_ix_aux are the ones that attempt to access the channel
%                     % Second (safety) condition: only 1 WLAN can be added to a state at a time 
%                     if length(wlan_ix_aux) == 1 
%                         % Third condition: the CCA condition in the previous state (psi_ix) is accomplished for the wlan attempting to access the channel (wlan_ix_aux)
%                         if Power_AP_PSI_cell{origin_psi_ix}( wlan_ix_aux ) < Power_Detection_PSI_cell{origin_psi_ix}(wlan_ix_aux)       
%                             % Fourth condition: check that the destination state is feasible
%                             transition_feasible = check_transition_feasibility_spatial_reuse(...
%                                 wlans, PSI_cell, Power_AP_PSI_cell, Power_Detection_PSI_cell, ...
%                                 origin_psi_ix, dest_psi_ix, wlan_ix_aux);                                                      
%                             if transition_feasible % TRANSITION IS FEASIBLE, ADD IT TO THE CTMN!
%                                 % Map the psi_ix to feasible space S
%                                 [~, origin_s_ix] = find_state_in_set(PSI_cell{origin_psi_ix}, S_cell);   
%                                 [~, dest_s_ix] = find_state_in_set(PSI_cell{dest_psi_ix}, S_cell);  
%                                 if logs_algorithm_on
%                                     disp([' + State ' num2str(origin_psi_ix)])
%                                     disp('   - Missing forward transition') 
%                                     disp(['   - Modifying Q for transition ' num2str(origin_s_ix) ...
%                                         ' (PSI_ix = ' num2str(origin_psi_ix) ') to ' num2str(dest_s_ix) ...
%                                         ' (PSI_ix = ' num2str(dest_psi_ix) ')' ])   
%                                 end
%                                 % Add forward transitions both at PSI and S
%                                 T_S(origin_s_ix, dest_s_ix) = FORWARD_TRANSITION;
%                                 T_PSI(origin_psi_ix, dest_psi_ix) = FORWARD_TRANSITION;
%                                 Q(origin_s_ix, dest_s_ix) = wlans(wlan_ix_aux).lambda;
%                             end
%                         end
%                     else
%                         disp('Unexpected transition. Two or more wlans are attempting to access the channel simultaneously!')
%                     end
%                 end  
%             end
%         end
%     end
  
    % Fill S 3D matrix
    S_num_states = length(S_cell);
    S = zeros(length(S_cell),num_wlans,num_channels_system);
    for k = 1 : S_num_states
        for width = 1 : num_wlans
            S(k,width,:) = S_cell{k}(width,:);
        end
    end
    
    % Fill Q 2D matrix
    for s = 1:length(Q)
        sum_rows = 0;
        for s_aux = 1:length(Q)
            if s ~= s_aux
                sum_rows = sum_rows + Q(s, s_aux);
            end
        end
        Q(s,s) = - sum_rows;
    end

end