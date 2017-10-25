%%% *********************************************************************
%%% * Spatial-Flexible CTMN for WLANs                                   *
%%% * Author: Sergio Barrachina-Munoz (sergio.barrachina@upf.edu)       *
%%% * Copyright (C) 2017-2022, and GNU GPLd, by Sergio Barrachina-Munoz *
%%% * GitHub repository: https://github.com/sergiobarra/SFCTMN          *
%%% * More info on https://www.upf.edu/en/web/sergiobarrachina          *
%%% *********************************************************************

function [ throughput ] = get_throughput( prob_tx_in_num_channels, num_wlans, num_channels_system )
    %GET_THROUGHPUT return the throughput of each WLAN
    % Input:
    %   - prob_tx_in_num_channels: array whose element w,n is the probability of WLAN w of transmiting in n channels
    %   - num_wlans: number of WLANs in the system
    %   - num_channels_system: number of channels in the system
    % Output:
    %   - throughput: array whose element w is the average throughput of WLAN w.
    
    load('constants.mat');  % Load constants into local workspace
    load('system_conf.mat');  % Load system configuration into local workspace

    throughput = zeros(num_wlans,1);
    
    for wlan_ix = 1 : num_wlans
        
        throughput(wlan_ix) = 0;    
        
        for num_ch = 1 : num_channels_system
            
            % Sergio on 5 Oct 2017: 
            % - replace hardocoded MU by 802.11ax data rate:
            % - throughput(wlan_ix) = throughput(wlan_ix) + (1 - PACKET_ERR_PROBABILITY) * NUM_PACKETS_AGGREGATED *...
            %    PACKET_LENGTH * (MU(num_ch) * prob_tx_in_num_channels(wlan_ix, num_ch + 1)) ./ 1E6;
            
            mu = 1 / SUtransmission80211ax(PACKET_LENGTH, NUM_PACKETS_AGGREGATED, num_ch * 20,...
                            SINGLE_USER_SPATIAL_STREAMS,MCS_INDEX);
            
            throughput(wlan_ix) = throughput(wlan_ix) + (1 - PACKET_ERR_PROBABILITY) * NUM_PACKETS_AGGREGATED *...
                PACKET_LENGTH * (mu * prob_tx_in_num_channels(wlan_ix, num_ch + 1)) ./ 1E6;            
            
        end
    end
end
