%%% *********************************************************************
%%% * Spatial-Flexible CTMN for WLANs                                   *
%%% * Author: Sergio Barrachina-Munoz (sergio.barrachina@upf.edu)       *
%%% * Copyright (C) 2017-2022, and GNU GPLd, by Sergio Barrachina-Munoz *
%%% * GitHub repository: https://github.com/sergiobarra/SFCTMN          *
%%% * More info on https://www.upf.edu/en/web/sergiobarrachina          *
%%% *********************************************************************

function [ possible_forward_states ] = find_possible_forward_states( ...
    PSI_cell, S_cell, num_global_states, num_wlans, k, wlan_ix, logs_algorithm_on)

%find_possible_forward_states returns the state (or states) that are
%feasible without checking them in detail. In other words, it provides the
%states at a given WLAN becomes active while the others remain the same
% Input:
%  - PSI_cell: cell with the all the possible states
%  - S_cell: cell with the current feasible states
%  - num_global_states: total number of states (global)
%  - num_wlans: number of WLANs
%  - k: index of the source state in S_cell
%  - wlan_ix: index of the WLAN to be inspected
%  - logs_algorithm_on: variable to print (or not) logs
% Output:
%  - possible_forward_states: array with the potential forward states

    load('constants_sfctmn_framework.mat');  % Load constants into workspace

    possible_forward_states = [];
    for psi_ix = 1 : num_global_states    % Foreach state psi in PSI
        % Flag determining if WLANs different from wlan (i.e. wlan_aux) remain the same in state s and psi
        other_wlans_remain_same = true; 
        for wlan_aux_ix = 1 : num_wlans   % Foreach WLAN
            % Condition I) Other WLANs in state s_psi must have same channel range that in s
            if wlan_aux_ix ~= wlan_ix  
                state_wlan_aux_in_s = S_cell{k}(wlan_aux_ix, :);
                state_wlan_aux_in_psi = PSI_cell{psi_ix}(wlan_aux_ix, :);
                % If wlan_aux different in s than psi
                if state_wlan_aux_in_s ~= state_wlan_aux_in_psi
                    other_wlans_remain_same = false;
                end                        
            end    
        end

        % Condition II) WLAN wlan must be active in state psi
        wlan_state_in_psi = PSI_cell{psi_ix}(wlan_ix, :);
        if wlan_state_in_psi > 0
           wlan_active_in_psi = true;
           left_ch_psi = 1;
           right_ch_psi = 1;
        else 
           wlan_active_in_psi = false;
           left_ch_psi = 0;
           right_ch_psi = 0;
        end

        % WLAN wlan should be active in state psi, while the rest of wlans should remain the same
        if other_wlans_remain_same && wlan_active_in_psi
            if logs_algorithm_on
                disp(['         - New suitable transition to s_psi #' num2str(psi_ix)...
                    ' with ch range: ' num2str(left_ch_psi) ' - ' num2str(right_ch_psi)]);
            end
            % Add global state psi to set of possible forward states (policy will pick one of them later)
            possible_forward_states = [possible_forward_states; psi_ix, left_ch_psi, right_ch_psi];  
        end
        
    end
    
end