%%% *********************************************************************
%%% * Spatial-Flexible CTMN for WLANs                                   *
%%% * Author: Sergio Barrachina-Munoz (sergio.barrachina@upf.edu)       *
%%% * Copyright (C) 2017-2022, and GNU GPLd, by Sergio Barrachina-Munoz *
%%% * GitHub repository: https://github.com/sergiobarra/SFCTMN          *
%%% * More info on https://www.upf.edu/en/web/sergiobarrachina          *
%%% *********************************************************************

function [ psi_forward, alpha ] = apply_dsa_policy( dsa_policy, possible_forward_states, Power_PSI_cell,...
        wlans, wlan_ix)
    
    %APPLY_DSA_POLICY returns the state (or states) to transit forward to depending on the DSA policy implemented
    % Input:
    %   - dsa_policy: type of DSA-DCB policy. It determines what channel range to pick depending on the sensed power
    %   - possible_forward_states: array of possible states to transit forward to
    %   - wlans: array of structures with wlans info
    %   - Power_PSI_cell: power sensed by every wlan in every channel in every global state [dBm]
    %   - wlan_ix: index of the WLAN currently being explored by the 'feasible state space' algorithm
    % Output:
    %   - psi_forward: state (or states) to transit forward to
    %   - alpha: array of transition rate tunning parameters
    
    load('constants.mat');  % Load constants into workspace
    load('system_conf.mat');  % Load system configuration into local workspace
    
    num_possible_forward_states = length(possible_forward_states(:,1)); % Number of possible states to transit forward
    psi_forward = [];        % State (or states) to transit forward to (it is determined by the DSA policy)
    alpha = [];
    max_ch_width = 0;       % Max channel width of the state providing max channel width
    
    switch dsa_policy
        
        % Transit to state with max channel width while power received in picked range < CCA
        case DSA_POLICY_AGGRESSIVE
            
            for state_possible_ix = 1 : num_possible_forward_states    % For each possible forward state
                
                % Possible forward state
                psi_possible_ix = possible_forward_states(state_possible_ix,1);
                % Left channel in possible forward state
                left_ch_psi = possible_forward_states(state_possible_ix,2);
                % Right channel in possible forward state
                rigth_ch_psi = possible_forward_states(state_possible_ix,3);
                % Channel width in possible forward state
                ch_width = rigth_ch_psi - left_ch_psi + 1;
                
                % Deterministic, i.e., will pick always the first range with max channel width. What
                % about picking one randomely from many options?
                if ch_width > max_ch_width
                    
                    cca_accomplished = true;    % Flag identifying if power sensed in evaluated range < CCA
                    
                    % CCA must be accomplished in every transmission channel
                    for ch_ix =  left_ch_psi : rigth_ch_psi
                        
                        % Power sensed in channel ch
                        power_sensed = Power_PSI_cell{psi_possible_ix}(wlan_ix,ch_ix);
                        
                        if power_sensed > wlans(wlann_ix).cca
                            cca_accomplished = false;
                        end
                    end
                    
                    if cca_accomplished
                        
                        max_ch_width = rigth_ch_psi - left_ch_psi;
                        
                        psi_forward(1) = psi_possible_ix;
                        alpha(1) = 1;   % Just one possible transition
                        
                    end
                end
            end
            
        % Transit only to states where only the primary channel is used for transmitting
        case DSA_POLICY_ONLY_PRIMARY
            
            for state_possible_ix = 1 : num_possible_forward_states    % For each possible forward state
                
                % Possible forward state
                psi_possible_ix = possible_forward_states(state_possible_ix,1);
                % Left channel in possible forward state
                left_ch_psi = possible_forward_states(state_possible_ix,2);
                % Right channel in possible forward state
                rigth_ch_psi = possible_forward_states(state_possible_ix,3);
                % Channel width in possible forward state
                ch_width = rigth_ch_psi - left_ch_psi + 1;
                
                if ch_width == 1
                    
                    cca_accomplished = true;    % Flag identifying if power sensed in evaluated range < CCA
                    
                    % CCA must be accomplished in primary channel
                    primary_ch = left_ch_psi;  % Left and right channel should be the same
                    % Power sensed in channel primary channel
                    power_sensed = Power_PSI_cell{psi_possible_ix}(wlan_ix,primary_ch);
                    
                    if power_sensed > wlans(wlann_ix).cca
                        cca_accomplished = false;
                    end
                    
                    if cca_accomplished
                        psi_forward(1) = psi_possible_ix;
                        alpha(1) = 1;   % Just one possible transition
                    end
                    
                end
            end
            
        % Transit only to states providing the whole available range for transmitting
        case DSA_POLICY_ONLY_MAX
            
            for state_possible_ix = 1 : num_possible_forward_states    % For each possible forward state
                
                % Possible forward state
                psi_possible_ix = possible_forward_states(state_possible_ix,1);
                % Left channel in possible forward state
                left_ch_psi = possible_forward_states(state_possible_ix,2);
                % Right channel in possible forward state
                rigth_ch_psi = possible_forward_states(state_possible_ix,3);
                % Channel width in possible forward state
                ch_width = rigth_ch_psi - left_ch_psi + 1;
                % Number of channels in WLAN wlan range
                wlan_num_channels_pickable = wlans(wlan_ix).range(2) - wlans(wlan_ix).range(1) + 1;
                
                if ch_width == wlan_num_channels_pickable
                    
                    cca_accomplished = true;    % Flag identifying if power sensed in evaluated range < CCA
                    
                    % CCA must be accomplished in every transmission channel
                    for ch_ix =  left_ch_psi : rigth_ch_psi
                        
                        % Power sensed in channel ch
                        power_sensed = Power_PSI_cell{psi_possible_ix}(wlan_ix,ch_ix);
                        
                        if power_sensed > wlans(wlann_ix).cca
                            cca_accomplished = false;
                        end
                    end
                    
                    if cca_accomplished
                        psi_forward(1) = psi_possible_ix;
                        alpha(1) = 1;   % Just one possible transition
                    end
                end
            end
            
            % Transit to states providing different transmission ranges uniformly
        case DSA_POLICY_EXPLORER_UNIFORM
            
            possible_forward_states_cca = [];   % Possible forward states compying with CCA
            
            for state_possible_ix = 1 : num_possible_forward_states    % For each possible forward state
                
                % Possible forward state
                psi_possible_ix = possible_forward_states(state_possible_ix,1);
                % Left channel in possible forward state
                left_ch_psi = possible_forward_states(state_possible_ix,2);
                % Right channel in possible forward state
                rigth_ch_psi = possible_forward_states(state_possible_ix,3);
                
                % CCA must be accomplished in every transmission channel
                
                cca_accomplished = true;    % Flag identifying if power sensed in evaluated range < CCA
                
                for ch_ix =  left_ch_psi : rigth_ch_psi
                    
                    % Power sensed in channel ch
                    power_sensed = Power_PSI_cell{psi_possible_ix}(wlan_ix,ch_ix);
                    
                    if power_sensed > wlans(wlann_ix).cca
                        cca_accomplished = false;
                    end
                end
                
                if cca_accomplished
                    
                    % Add state to possible forward states complying with CCA
                    possible_forward_states_cca = [possible_forward_states_cca; psi_possible_ix];
                    
                end
                
            end
            
            psi_forward = possible_forward_states_cca;
            
            % *** Handle alphas here modifying Q ! ***
            
            num_possible_forward_states_cca = length(possible_forward_states_cca);
            alpha(1:num_possible_forward_states_cca) = 1 / num_possible_forward_states_cca;
            
            % Transit to states providing different transmission ranges according to sergio's 'ladder' distribution
        case DSA_POLICY_EXPLORER_LADDER
            
            possible_forward_states_cca = [];   % Possible forward states compying with CCA
            
            for state_possible_ix = 1 : num_possible_forward_states    % For each possible forward state
                
                % Possible forward state
                psi_possible_ix = possible_forward_states(state_possible_ix,1);
                % Left channel in possible forward state
                left_ch_psi = possible_forward_states(state_possible_ix,2);
                % Right channel in possible forward state
                rigth_ch_psi = possible_forward_states(state_possible_ix,3);
                
                % CCA must be accomplished in every transmission channel
                
                cca_accomplished = true;    % Flag identifying if power sensed in evaluated range < CCA
                
                for ch_ix =  left_ch_psi : rigth_ch_psi
                    
                    % Power sensed in channel ch
                    power_sensed = Power_PSI_cell{psi_possible_ix}(wlan_ix,ch_ix);
                    
                    if power_sensed > wlans(wlann_ix).cca
                        cca_accomplished = false;
                    end
                end
                
                if cca_accomplished
                    
                    % Add state to possible forward states complying with CCA
                    possible_forward_states_cca = [possible_forward_states_cca;...
                        [psi_possible_ix, left_ch_psi, rigth_ch_psi]];
                    
                end
                
            end
            
            if ~isempty(possible_forward_states_cca)
                
                psi_forward = possible_forward_states_cca(:,1);
                
                % alphas
                num_possible_forward_states_cca = size(possible_forward_states_cca, 1);
                
                % Maybe not to optimal and nice to have two fors with same indeces :)
                sum_possible_channel_widths = 0;
                for psi_forward_aux_ix = 1 : num_possible_forward_states_cca
                    
                    ch_width = possible_forward_states_cca(psi_forward_aux_ix, 3) -...
                        possible_forward_states_cca(psi_forward_aux_ix, 2) + 1;
                    
                    sum_possible_channel_widths = sum_possible_channel_widths + ch_width;
                    
                end
                
                for psi_forward_aux_ix = 1 : num_possible_forward_states_cca
                    
                    ch_width = possible_forward_states_cca(psi_forward_aux_ix, 3) -...
                        possible_forward_states_cca(psi_forward_aux_ix, 2) + 1;
                    
                    alpha(psi_forward_aux_ix) = ch_width / sum_possible_channel_widths;
                    
                end
            end
            
            % Unkown DSA policy
        otherwise
            error('Unknown DSA policy!')
    end
end