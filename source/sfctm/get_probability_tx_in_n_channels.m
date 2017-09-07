%%% *********************************************************************
%%% * Spatial-Flexible CTMN for WLANs                                   *
%%% * Author: Sergio Barrachina-Munoz (sergio.barrachina@upf.edu)       *
%%% * Copyright (C) 2017-2022, and GNU GPLd, by Sergio Barrachina-Munoz *
%%% * GitHub repository: https://github.com/sergiobarra/SFCTMN          *
%%% * More info on https://www.upf.edu/en/web/sergiobarrachina          *
%%% *********************************************************************

function [ prob_tx_in_num_channels_success, prob_tx_in_num_channels_unsuccess ] = get_probability_tx_in_n_channels( Power_PSI_cell, S_cell, PSI_cell, ...
        num_wlans, num_channels_system, p_equilibrium, path_loss_model,  distance_ap_sta, wlans , carrier_frequency)
    %GET_PROBABILITY_TX_IN_N_CHANNELS returns the probability of transmitting in a given number of channels
    % Input:
    %   - Power_PSI_cell: power sensed by every wlan in every channel in every global state [dBm]
    %   - PSI_cell: cell array representing the global states
    %   - S_cell: cell array representing the feasible states
    %   - num_wlans: number of WLANs in the system
    %   - num_channels_system:  number of channels in the system
    %   - p_equilibrium: equilibrium distribution array (pi)
    %   - path_loss_model: path loss model
    %   - distance_ap_sta: distance between the AP and STAs of a WLAN
    %   - wlans: array of structures with wlans info
    %   - carrier_frequency: carrier frequency [Hz]
    % Output:
    %   - prob_tx_in_num_channels: array whose element w,n is the probability of WLAN w of transmiting in n channels
   
    load('constants.mat');  % Load constants into workspace
    
    S_num_states = length(S_cell);  % Number of feasible states

    prob_tx_in_num_channels_success = zeros(num_wlans, num_channels_system + 1);    
    
    prob_tx_in_num_channels_unsuccess = zeros(num_wlans, num_channels_system + 1); 

    for s_ix = 1 : S_num_states
        
%         disp(['- state: ' num2str(s_ix)])
        
        pi_s = p_equilibrium(s_ix); % probability of being in state s

        for wlan_ix = 1 : num_wlans
            
%             disp(['  · wlan: ' num2str(wlan_ix)])
            
            % Number of channels used by WLAN wlan in state s
            [left_ch, right_ch, is_wlan_active ,num_channels] = get_channel_range(S_cell{s_ix}(wlan_ix,:));
            
            capture_effect_accomplished = true;    % Flag identifying if power sensed in evaluated range < CCA

            if is_wlan_active
                
                % CCA must be accomplished in every transmission channel
                for ch_ix =  left_ch : right_ch
                    
                    % Power sensed in channel ch
                    
                    [ ~, psi_s_ix ] = find_state_in_set( S_cell{s_ix}, PSI_cell );
                    
                    interest_power = compute_power_received(distance_ap_sta, wlans(wlan_ix).tx_power, GAIN_TX_DEFAULT,...
                        GAIN_RX_DEFAULT, carrier_frequency, path_loss_model);
                   
                    interference_power = Power_PSI_cell{psi_s_ix}(wlan_ix,ch_ix);
                    
                    sinr = compute_sinr(interest_power, interference_power, NOISE_DBM);
                    
%                     disp(['    * sinr(ch = ' num2str(ch_ix) ') = ' num2str(sinr)])
                    
                    if sinr < CAPTURE_EFFECT
                        capture_effect_accomplished = false;
                    end
                end

                if capture_effect_accomplished
                    prob_tx_in_num_channels_success(wlan_ix, num_channels + 1) = prob_tx_in_num_channels_success(wlan_ix, num_channels + 1)...
                    + pi_s;
                else
                    prob_tx_in_num_channels_unsuccess(wlan_ix, num_channels + 1) = prob_tx_in_num_channels_unsuccess(wlan_ix, num_channels + 1)...
                    + pi_s;
                end
            end            
        end
    end
end

