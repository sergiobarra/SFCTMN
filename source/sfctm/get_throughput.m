%%% *********************************************************************
%%% * Spatial-Flexible CTMN for WLANs                                   *
%%% * Author: Sergio Barrachina-Munoz (sergio.barrachina@upf.edu)       *
%%% * Copyright (C) 2017-2022, and GNU GPLd, by Sergio Barrachina-Munoz *
%%% * GitHub repository: https://github.com/sergiobarra/SFCTMN          *
%%% * More info on https://www.upf.edu/en/web/sergiobarrachina          *
%%% *********************************************************************

function [ throughput ] = get_throughput(  wlans, num_wlans, p_equilibrium, ...
    S_cell, PSI_cell, SINR_cell, mcs_per_wlan, power_from_ap )
%GET_THROUGHPUT return the throughput of each WLAN
% Input:
%   - prob_tx_in_num_channels: array whose element w,n is the probability of WLAN w of transmiting in n channels
%   - num_wlans: number of WLANs in the system
%   - num_channels_system: number of channels in the system
% Output:
%   - throughput: array whose element w is the average throughput of WLAN w.

    load('constants.mat');  % Load constants into workspace
    load('system_conf.mat');

    throughput = zeros(num_wlans,1);

    for state_ix = 1 : size(S_cell, 2)

        pi_s = p_equilibrium(state_ix); % probability of being in state s
        
        disp(['State ix: ' num2str(state_ix)])
        disp(['pi_s: ' num2str(pi_s)])

        for wlan_ix = 1 : num_wlans

            disp([' * WLAN ix: ' num2str(wlan_ix)])

            interest_power = power_from_ap(wlan_ix, wlan_ix);

            % Number of channels used by WLAN wlan in state s
            [left_ch, right_ch, is_wlan_active, num_channels] = get_channel_range(S_cell{state_ix}(wlan_ix,:));

            capture_effect_accomplished = true;    % Flag identifying if power sensed in evaluated range < CCA
            
            if is_wlan_active

                % PSI's index of the backward transition origin state
                [~, origin_psi_ix] = find_state_in_set(S_cell{state_ix}, PSI_cell);

                % CCA must be accomplished in every transmission channel
                for ch_ix =  left_ch : right_ch

                    sinr = SINR_cell{origin_psi_ix}(wlan_ix, ch_ix);
                    
    %                 if PSI_cell{origin_psi_ix}(wlan_ix, wlans(wlan_ix).primary) == 1 ...
    %                         && sinr > CAPTURE_EFFECT && interest_power > wlans(wlan_ix).cca
                    
                    if (sinr < CAPTURE_EFFECT) || (interest_power < wlans(wlan_ix).cca)

                        capture_effect_accomplished = false;                    

                    end
                end
                
                disp(['    * WLAN ix: ' num2str(wlan_ix)])   
                disp(['    * sinr: ' num2str(sinr)])   
                disp(['    * interest_power: ' num2str(interest_power)])   
                disp(['    * CCA: ' num2str(wlans(wlan_ix).cca)])  
                disp(['    * num_channels: ' num2str(num_channels)])  
                disp(['    * MCS used: ' num2str(mcs_per_wlan(wlan_ix, log2(num_channels)+1))])

                % Clear tx_time
                tx_time = 0;

                if capture_effect_accomplished

                    tx_time = SUtransmission80211ax(PACKET_LENGTH, NUM_PACKETS_AGGREGATED, ...
                       num_channels, SINGLE_USER_SPATIAL_STREAMS, ...
                       mcs_per_wlan(wlan_ix, log2(num_channels)+1));
                      
                    mu = 1/tx_time;     
                   
                else

                    mu = 0; 

                end
                                
                throughput(wlan_ix) = throughput(wlan_ix) + (1 - PACKET_ERR_PROBABILITY) * NUM_PACKETS_AGGREGATED *...
                    PACKET_LENGTH * mu * pi_s ./ 1E6;  
                
                disp([' * throughput: ' num2str(throughput(wlan_ix))])  

            end

        end
    end
end