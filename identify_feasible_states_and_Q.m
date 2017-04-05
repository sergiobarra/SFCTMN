%%% WLAN CTMC Analysis
%%% Author: Sergio Barrachina (sergio.barrachina@upf.edu)
%%% File description: function for finding the feasible state space (S) and transition rate matrix (Q) of a
%%%     given WLAN system taking the power sensed in the interest spectrum into consideration

function [ Q, S, S_cell, T_S, T_PSI, S_num_states ] = identify_feasible_states_and_Q( PSI_cell, Power_PSI_cell,...
        num_channels_system, wlans, dsa_policy, logs_algorithm_on )
    %IDENTIFY_FEASIBLE_STATES returns the set of global states according a given channel access protocol
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
    
    load('constants.mat');  % Load constants into workspace
    
    if logs_algorithm_on
        disp(' ');
        disp('--- IDENTIFYING FEASIBLE STATES (S) ---');
    end
    
    num_global_states = length(PSI_cell);   % Number of global states
    num_wlans = length(wlans);              % Number of WLANs
    T_PSI = zeros(num_global_states, num_global_states);    % Logical transition rates matrix in global space PSI
    T_S = [];                   % Logical transitions matrix in feasible state space S
    i = 1;                      % Index of the last state found by the algorithm
    k = 1;                      % Index of the state currently being used by the algorithm for discovery
    S_cell{1} = PSI_cell{1};    % Set of feasible states. Empty state always belong to S
    Q = []; % S's transition rate matrix
    
    while k <= length(S_cell)   % While there are known states in S not explored yet
        
        if logs_algorithm_on
            [~, psi_ix] = find_state_in_set(S_cell{k}, PSI_cell);
            disp(['s' num2str(k) ' (s_psi #' num2str(psi_ix) '):']);
            disp(S_cell{k})
        end

        for wlan_ix = 1 : num_wlans     % Foreach WLAN

            % Determine if wlan is active in state s
            wlan_ch_range = S_cell{k}(wlan_ix,:);    % Channel range of WLAN wlan in state s
            [~, ~, wlan_active_in_s] = get_channel_range(wlan_ch_range);
            
            % If wlan is ACTIVE in s ---> set backward transitions to known and unknown states
            if wlan_active_in_s
                               
                for psi_ix = 1 : num_global_states  % For each state in PSI (psi)
                      
                    % Flag determining if WLANs different from wlan (i.e. wlan_aux) remain the same in state s and psi
                    other_wlans_remain_same = true; 

                    for wlan_aux_ix = 1 : num_wlans     % Foreach WLAN

                        % Condition I) Other WLANs in new state psi (active or not) must have same channel range that in s
                        if wlan_aux_ix ~= wlan_ix   % Different WLAN than wlan

                            % Channel range of wlan_aux in state s
                            ch_range_wlan_aux_in_s = S_cell{k}(wlan_aux_ix,:);
                            % Channel range of wlan_aux in state psi
                            ch_range_wlan_aux_in_psi = PSI_cell{psi_ix}(wlan_aux_ix,:);

                            % If wlan_aux different in s than psi
                            if ~isequal(ch_range_wlan_aux_in_s, ch_range_wlan_aux_in_psi)
                                other_wlans_remain_same = false;
                            end
                        end
                    end

                    % Channel range of WLAN wlan in state psi
                    ch_range_wlan_in_psi =  PSI_cell{psi_ix}(wlan_ix,:);
                    % Condition II) WLAN wlan must be NOT active in state receiving the backward transition
                    [~, ~, wlan_active_in_psi] = get_channel_range(ch_range_wlan_in_psi);

                    % WLAN wlan should be NOT active in state psi, while the rest of wlans should remain the same
                    if other_wlans_remain_same && ~wlan_active_in_psi

                        origin_s_ix = k; % S's index of the backward transition origin state 
                        % S's index of the backward transition destination state (if exists in S)
                        [is_psi_in_s, destination_s_ix] = find_state_in_set(PSI_cell{psi_ix}, S_cell);
                        % PSI's index of the backward transition origin state 
                        [~, origin_psi_ix] = find_state_in_set(S_cell{k}, PSI_cell);
                        % PSI's desitnation index of the backward transition destination state
                        destination_psi_ix = psi_ix;
                        
                        if ~is_psi_in_s     % If destination state NOT known in S, add it
                            
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
                        % Number of channels used by WLAN wlan in current state s
                        [~, ~, ~, num_ch_wlan_s, ] = get_channel_range(S_cell{k}(wlan_ix,:));
                        % Departure rate of WLAN wlan in current state s
                        mu_s = MU(num_ch_wlan_s);
                        
                        Q(origin_s_ix, destination_s_ix) = mu_s;
                        T_PSI(origin_psi_ix, destination_psi_ix) = BACKWARD_TRANSITION;

                        if logs_algorithm_on
                            disp(['   * New backward transition from s' num2str(origin_s_ix)...
                                ' (s_psi #'  num2str(origin_psi_ix) ') to ' num2str(destination_s_ix)...
                                ' (s_psi #' num2str(destination_psi_ix) ')']);
                        end
                    end
                end
                
            % If wlan is NOT ACTIVE in s ---> find forward transitions to other states if any
            else    
                
                % Look if there are states in PSI (psi) that that differs from s only by the participation of WLAN wlan
                % and include them in array possible_forward_states
                possible_forward_states = [];
                
                for psi_ix = 1 : num_global_states    % Foreach state psi in PSI

                    % Flag determining if WLANs different from wlan (i.e. wlan_aux) remain the same in state s and psi
                    other_wlans_remain_same = true; 

                    for wlan_aux_ix = 1 : num_wlans   % Foreach WLAN

                        % Condition I) Other WLANs in state s_psi must have same channel range that in s
                        if wlan_aux_ix ~= wlan_ix  

                            % Channel range of wlan_aux in state s                           
                            ch_range_wlan_aux_in_s = S_cell{k}(wlan_aux_ix,:);
                            % Channel range of wlan_aux in state psi
                            ch_range_wlan_aux_in_psi = PSI_cell{psi_ix}(wlan_aux_ix,:);

                            % If wlan_aux different in s than psi
                            if ~isequal(ch_range_wlan_aux_in_s, ch_range_wlan_aux_in_psi)
                                other_wlans_remain_same = false;
                            end

                        % Condition II) WLAN wlan must be active in state psi
                        else
                            [left_ch_psi, rigth_ch_psi, wlan_active_in_s_psi] =...
                                get_channel_range(PSI_cell{psi_ix}(wlan_aux_ix,:));
                        end
                    end

                    % WLAN wlan should be active in state psi, while the rest of wlans should remain the same
                    if other_wlans_remain_same && wlan_active_in_s_psi

                        if logs_algorithm_on
                            disp(['         - New suitable transition to s_psi #' num2str(psi_ix)...
                                ' with ch range: ' num2str(left_ch_psi) ' - ' num2str(rigth_ch_psi)]);
                        end

                        % Add global state psi to set of possible forward states (policy will pick one of them later)
                        possible_forward_states = [possible_forward_states; psi_ix, left_ch_psi, rigth_ch_psi];
                    end
                end

                % If there are possible global states to transit to from current state s
                if ~isempty(possible_forward_states) 
                                       
                    % State to transit forward to (psi_forward) depends on the DSA policy applied
                    [psi_forward alfa] = apply_dsa_policy( dsa_policy, possible_forward_states, Power_PSI_cell, wlans, wlan_ix);

                    if ~isempty(psi_forward)  % If there is a global state to transit to from current state s
                        
                        for psi_forward_aux_ix = 1 : length(psi_forward)
                            
                            % S's index of the backward transition origin state 
                            origin_s_ix = k; 
                            % S's index of the backward transition destination state (if exists in S)
                            [is_psi_forward_in_s, destination_s_ix] =...
                                find_state_in_set(PSI_cell{psi_forward(psi_forward_aux_ix)}, S_cell);

                            % PSI's index of the backward transition origin state                         
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

                            T_PSI(origin_psi_ix, destination_psi_ix) = FORWARD_TRANSITION;
                            T_S(origin_s_ix, destination_s_ix) = FORWARD_TRANSITION;
                            
                            % Now we introduce the alfa weights! :D
                            % Q(origin_s_ix, destination_s_ix) = wlans(wlan_ix).lambda;
                            Q(origin_s_ix, destination_s_ix) = alfa(psi_forward_aux_ix) * wlans(wlan_ix).lambda;

                            if logs_algorithm_on
                                disp(['   * New forward transition from s' num2str(origin_s_ix)...
                                    ' (s_psi #' num2str(origin_psi_ix) ') to s' num2str(destination_s_ix)...
                                    ' (s_psi #' num2str(destination_psi_ix) ')']);
                            end
                        end
                    end
                end
            end
        end    

        k = k + 1;  % Update index of the state used for state and transition discovery
    end

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

