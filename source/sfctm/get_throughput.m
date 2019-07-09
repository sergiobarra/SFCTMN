%%% *********************************************************************
%%% * Spatial-Flexible CTMN for WLANs                                   *
%%% * Author: Sergio Barrachina-Munoz (sergio.barrachina@upf.edu)       *
%%% * Copyright (C) 2017-2022, and GNU GPLd, by Sergio Barrachina-Munoz *
%%% * GitHub repository: https://github.com/sergiobarra/SFCTMN          *
%%% * More info on https://www.upf.edu/en/web/sergiobarrachina          *
%%% *********************************************************************

function [ throughput ] = get_throughput(  wlans, num_wlans, p_equilibrium, S_cell, ...
    PSI_cell, SINR_cell, mcs_per_wlan, Power_Detection_PSI_cell, Interest_Power_PSI_cell )
%GET_THROUGHPUT return the throughput of each WLAN
% Input:
%   - prob_tx_in_num_channels: array whose element w,n is the probability of WLAN w of transmiting in n channels
%   - num_wlans: number of WLANs in the system
%   - num_channels_system: number of channels in the system
% Output:
%   - throughput: array whose element w is the average throughput of WLAN w.

    % Load constants into workspace
    load('constants_sfctmn_framework.mat');  
    load('configuration_system.mat');
    % Initialize the array of throughput
    throughput = zeros(num_wlans,1);
    % Iterate for each state in feasible space S
    for s_ix = 1 : size(S_cell, 2)
        % Get the probability of being in state s
        pi_s = p_equilibrium(s_ix); 
        % Iterate for each WLAN
        for wlan_ix = 1 : num_wlans
            num_channels = 1;            
            capture_effect_accomplished = true;    % Flag identifying if power sensed in evaluated range < CCA          
            % PSI's index of the backward transition origin state
            [~, psi_ix] = find_state_in_set(S_cell{s_ix}, PSI_cell);             
            % If "wlan_ix" is active in state "psi_ix"
            if PSI_cell{psi_ix}(wlan_ix) > 0                 
                interest_power = Interest_Power_PSI_cell{psi_ix}(wlan_ix);
                sinr = SINR_cell{psi_ix}(wlan_ix);
                if (sinr < CAPTURE_EFFECT) || (interest_power < wlans(wlan_ix).cca) %Power_Detection_PSI_cell{psi_ix}(wlan_ix))
                    capture_effect_accomplished = false;              
                end      
                
                if wlan_ix == 1 && PSI_cell{psi_ix}(wlan_ix) > 1
                    tx_power = apply_tx_power_restriction(Power_Detection_PSI_cell{psi_ix}(wlan_ix), ...
                        wlans(wlan_ix).tx_pwr_ref, TX_POWER_MAX, OBSS_PD_MIN, num_channels);
                end
                
                % Compute the tx time spent in "psi_ix"
                [tx_time, limited_num_pack_agg] = SUtransmission80211ax(PACKET_LENGTH, NUM_PACKETS_AGGREGATED, ...
                    num_channels * CHANNEL_WIDTH_MHz, SINGLE_USER_SPATIAL_STREAMS, mcs_per_wlan{psi_ix}(wlan_ix), false);    
                
                % If the CE condition is accomplisehd, compute "mu" for state "psi_ix"
                if capture_effect_accomplished                                             
                    % Compute "mu" in psi_ix
                    mu = 1/tx_time;                   
                else
                    % Set "mu" to 0 since data cannot be properly received
                    mu = 0; 
                end
                % Add the throughput of "psi_ix" to the total throughput of wlan "wlan_ix"            
                throughput(wlan_ix) = throughput(wlan_ix) + ...
                    (1 - PACKET_ERR_PROBABILITY) * limited_num_pack_agg *...
                    PACKET_LENGTH * mu * pi_s ./ 1E6;                                          
            end
        end
    end
end