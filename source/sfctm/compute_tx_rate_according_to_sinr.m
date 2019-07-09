function [ tx_rate ] = compute_tx_rate_according_to_sinr( SINR, n_channels )
    %compute_data_rate computes the data rate of each WLAN in every channel in every global state. 
    % Input:
    %   - wlans: array of structures with wlans info
    % Output: 
    %   - Power_from_AP: array of power sensed in the STA from its AP (in dBm)

    load('constants_sfctmn_framework.mat');  % Load constants into workspace
    
    if n_channels > 0 && SINR > 0
        tx_rate = n_channels * CHANNEL_WIDTH * log2(1 + db2pow(SINR));
    else
        tx_rate = MINIMUM_TX_RATE;
    end
        
end