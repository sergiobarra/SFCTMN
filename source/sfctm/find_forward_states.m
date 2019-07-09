%%% *********************************************************************
%%% * Spatial-Flexible CTMN for WLANs                                   *
%%% * Author: Sergio Barrachina-Munoz (sergio.barrachina@upf.edu)       *
%%% * Copyright (C) 2017-2022, and GNU GPLd, by Sergio Barrachina-Munoz *
%%% * GitHub repository: https://github.com/sergiobarra/SFCTMN          *
%%% * More info on https://www.upf.edu/en/web/sergiobarrachina          *
%%% *********************************************************************

function [ psi_forward, alpha ] = find_forward_states( possible_forward_states, ...
    PSI_cell, Power_AP_PSI_cell, Power_Detection_PSI_cell, ...
    Individual_Power_AP_PSI_cell, wlans, wlan_ix, origin_psi_ix )

%APPLY_DSA_POLICY returns the state (or states) to transit forward to depending on the DSA policy implemented
% Input:
%   - possible_forward_states: array of possible states to transit forward to
%   - wlans: array of structures with wlans info
%   - Power_PSI_cell: power sensed by every wlan in every channel in every global state [dBm]
%   - wlan_ix: index of the WLAN currently being explored by the 'feasible state space' algorithm
% Output:
%   - psi_forward: state (or states) to transit forward to
%   - alpha: array of transition rate tunning parameters

    load('constants_sfctmn_framework.mat');  % Load constants into workspace

    % Number of possible states to transit forward
    num_possible_forward_states = length(possible_forward_states(:,1)); 
    % State(s) for forward transitions (determined by the DSA policy)
    psi_forward = [];   
    % Probability of going to each state in psi_forward (FIXED TO 1)
    alpha = [];     
    
    % disp(['+ wlan ' num2str(wlan_ix)])
    % Iterate for each possible forward state 
    for ix = 1 : num_possible_forward_states
        psi_possible_ix = possible_forward_states(ix, 1); % Possible forward state
        % Find which WLANs are transmitting in state origin_psi_ix
        active_wlans = find(PSI_cell{origin_psi_ix}>0);   
        % Check which modes are allowed to be used (according to the PD threshold)
        % 1 - Find the type of the ongoing transmissions and the maximum power received from each one
        SR_modes = zeros(1, 3); % Variable to keep track of the type of ongoing transmission
        SR_max_power_received = -Inf*ones(1, 3); % Variable to keep track of the maximum power received from each type of ongoing transmission
        if active_wlans >= 1 % If there is more than one active WLAN, check which mode is allowed to be used
            for w = 1 : size(active_wlans) % Iterate for each active wlan different than "wlan_ix"
                if wlan_ix ~= active_wlans(w)
                   % In case SRG is activated
                   if wlans(wlan_ix).non_srg_activated 
                       if wlans(wlan_ix).srg > 0 && wlans(active_wlans(w)).srg > 0 && ...
                           wlans(wlan_ix).srg == wlans(active_wlans(w)).srg  % Same SRG case
                            SR_modes(3) = 1;
                            if(Individual_Power_AP_PSI_cell{origin_psi_ix}(wlan_ix, active_wlans(w)) > SR_max_power_received(3)) 
                                SR_max_power_received(3) = Individual_Power_AP_PSI_cell{origin_psi_ix}(wlan_ix, active_wlans(w));
                            end
                       else  % Different SRG case (non-SRG)
                            SR_modes(2) = 1;
                            if(Individual_Power_AP_PSI_cell{origin_psi_ix}(wlan_ix, active_wlans(w)) > SR_max_power_received(2)) 
                                SR_max_power_received(2) = Individual_Power_AP_PSI_cell{origin_psi_ix}(wlan_ix, active_wlans(w));
                            end
                       end
                   else % Legacy capabilities
                        SR_modes(1) = 1;
                        if(Individual_Power_AP_PSI_cell{origin_psi_ix}(wlan_ix, active_wlans(w)) > SR_max_power_received(1)) 
                            SR_max_power_received(1) = Individual_Power_AP_PSI_cell{origin_psi_ix}(wlan_ix, active_wlans(w));
                        end
                    end
                end    
            end
        end
        % 2 - Check if the destination state is allowed, according to the possible allowed modes
        transition_feasible = false;
        allowed_state = 0;
        if sum(SR_modes) > 0
            % Check legacy mode
            if SR_modes(1) && SR_max_power_received(1) < wlans(wlan_ix).cca
                allowed_state = 1;
            % Check non-SRG mode
            elseif SR_modes(2) && SR_max_power_received(2) < wlans(wlan_ix).non_srg_obss_pd
                if SR_max_power_received(2) > wlans(wlan_ix).cca
                    allowed_state = 2;
                else
                    allowed_state = 1;
                end
            % Check SRG mode    
            elseif SR_modes(3) && SR_max_power_received(3) < wlans(wlan_ix).srg_obss_pd
                if SR_max_power_received(3) > wlans(wlan_ix).cca
                    allowed_state = 3;
                else
                    allowed_state = 1;
                end
            end
        else 
            allowed_state = 1;
        end
        
         % Check if the destination state matches with the allowed types of state to transit to
        if PSI_cell{psi_possible_ix}(wlan_ix) == allowed_state
            transition_feasible = true;
        end
        
%             Power_AP_PSI_cell, Power_Detection_PSI_cell, origin_psi_ix, psi_possible_ix, wlan_ix);
%             if psi_possible_ix == 6 && origin_psi_ix == 2
%                 disp(['+ wlan ' num2str(wlan_ix)])
%                 disp(['   * origin_psi_ix ' num2str(origin_psi_ix)])
%                 disp(['          - psi_possible_ix ' num2str(psi_possible_ix)])
%                 disp(['          - Power_PSI_cell ' num2str(Power_PSI_cell{origin_psi_ix}(wlan_ix))])
%                 disp(['          - Power_Detection_PSI_cell ' num2str(Power_Detection_PSI_cell{psi_possible_ix}(wlan_ix))])
%                 disp(['          - transition_feasible ' num2str(transition_feasible)])
%             end
        
        % 3 - Check if the channel is sensed as idle, according to the required PD threshold
        power_sensed = Power_AP_PSI_cell{psi_possible_ix}( wlan_ix );  % Power sensed in channel primary channel
        condition_sr = true;
        if PSI_cell{psi_possible_ix}(wlan_ix) > 1 && power_sensed < wlans(wlan_ix).cca % Additional condition for SR: the power sensed must be higher than the default CCA
            condition_sr = false;
        end 
        
        % Check if psi_forward can be included
        if transition_feasible && condition_sr
            % Check if the CCA condition is accomplished
            if power_sensed < Power_Detection_PSI_cell{psi_possible_ix}(wlan_ix)
                % Add "psi_possible_ix" to forward states
                psi_forward = [psi_forward psi_possible_ix];
                alpha(ix) = 1;   % Just one possible transition
            end
        end
        
    end
            
end