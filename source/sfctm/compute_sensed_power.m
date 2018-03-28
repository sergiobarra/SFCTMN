%%% *********************************************************************
%%% * Spatial-Flexible CTMN for WLANs                                   *
%%% * Author: Sergio Barrachina-Munoz (sergio.barrachina@upf.edu)       *
%%% * Copyright (C) 2017-2022, and GNU GPLd, by Sergio Barrachina-Munoz *
%%% * GitHub repository: https://github.com/sergiobarra/SFCTMN          *
%%% * More info on https://www.upf.edu/en/web/sergiobarrachina          *
%%% *********************************************************************

function [ Power_AP_PSI_cell, Power_STA_PSI_cell, SINR_cell ] = compute_sensed_power( wlans, num_global_states, PSI_cell,...
        path_loss_model, carrier_frequency, flag_general_logs, power_sta_from_ap, distance_ap_ap, distance_ap_sta, num_channels_system)
    %COMPUTE_SENSED_POWER computes the sensed power of each WLAN in every channel in every global state. 
    % Input:
    %   - wlans: array of structures with wlans info
    %   - num_global_states: number of global states
    %   - PSI_cell: set of global states in cell array form
    %   - path_loss_model: path loss model
    %   - d_sta: distance between AP and STAs inside the same WLAN
    %   - carrier_frequency: carrier frequency
    %   - Power_from_AP: power that each STA receives from its AP (in dBm)
    
    load('constants.mat');  % Load constants into workspace
    load('system_conf.mat');  % Load constants into workspace
    
    % Set of powers [dBm] sensed in the AP in cell array form. Item {s}(w,c) is the power sensed by AP in WLAN w in channel c in state s.
    Power_AP_PSI_cell = {};
    P_AP_PSI_linear_cell = {};     % P_PSI_cell with linear powers (for convenience when summing)
    
    % Set of powers [dBm] sensed in the STA in cell array form. Item {s}(w,c) is the power sensed by STA in WLAN w in channel c in state s.
    Power_STA_PSI_cell = {};
    P_STA_PSI_linear_cell = {};
    
    % Set of SINR [dBm] in cell array form. Item {s}(w,c) is the SINR in STA of WLAN w in channel c in state s.
    SINR_cell = {};
    
    % Set of TX rates [bps] in cell array form. Item {s}(w,c) is the data rate in AP of WLAN w in channel c in state s.
    Tx_Rate_cell = {};
       
    num_wlans = length(wlans);  % Number of WLANs
    
    log_k = round(num_global_states/10);    % Auxiliar variable for displaying execution evolution in the terminal
    
    for psi_ix = 1 : num_global_states
        
        % Display evolution in command line
        if mod(psi_ix, log_k) == 0
             display_with_flag(['   * ' num2str(round(psi_ix*100/num_global_states)) ' %'], flag_general_logs)
        end
        
        for wlan_ix = 1 : num_wlans
            
            n_channels_used_for_tx = sum(PSI_cell{psi_ix}(wlan_ix,:)); % For each channel used during tx, use -3 dBm of power        
            %n_channels_used_for_tx = 1;
                        
            for c = 1 : num_channels_system
                
                sum_power_rx_ap_linear = 0;
                sum_power_rx_sta_linear = 0;    
                               
                for w_aux = 1 : num_wlans
                    
                    if wlan_ix ~= w_aux                        
                                                
                        if PSI_cell{psi_ix}(w_aux,c) % If wlan_aux transmitting in state s
                            
                            distance_w_ap = distance_ap_ap(wlan_ix, w_aux);
                            distance_w_sta = distance_ap_sta(w_aux, wlan_ix);
                                                        
                            % Transmission power must be divided by the number of channels 
                            [~, ~, ~, num_channels, ~] = get_channel_range( PSI_cell{psi_ix}(w_aux,:) );
                            tx_power = wlans(w_aux).tx_power - 3 * (num_channels - 1);    % 3dB less
                                                        
                            % Compute the power received in the AP
                            pw_rx_ap_dBm = compute_power_received(distance_w_ap, tx_power,...
                                GAIN_TX_DEFAULT, GAIN_RX_DEFAULT, carrier_frequency, path_loss_model);
                            
                            pw_rx_ap_linear = 10^(pw_rx_ap_dBm/10);
                            sum_power_rx_ap_linear = sum_power_rx_ap_linear + pw_rx_ap_linear;
                            
                            % Compute the power received in the STA
                            pw_rx_sta_dBm = compute_power_received(distance_w_sta, tx_power,...
                                GAIN_TX_DEFAULT, GAIN_RX_DEFAULT, carrier_frequency, path_loss_model);
                            
                            pw_rx_sta_linear = 10^(pw_rx_sta_dBm/10);
                            sum_power_rx_sta_linear = sum_power_rx_sta_linear + pw_rx_sta_linear;
                            
                        end
                    end
                end
                % Power received at the AP
                P_AP_PSI_linear_cell{psi_ix}(wlan_ix, c) = sum_power_rx_ap_linear;
                Power_AP_PSI_cell{psi_ix}(wlan_ix, c) = 10 * log10(P_AP_PSI_linear_cell{psi_ix}(wlan_ix,c));
                % Power received at the STA
                P_STA_PSI_linear_cell{psi_ix}(wlan_ix, c) = sum_power_rx_sta_linear;
                Power_STA_PSI_cell{psi_ix}(wlan_ix, c) = 10 * log10(P_STA_PSI_linear_cell{psi_ix}(wlan_ix,c));
                                   
                % Compute the SINR for state "psi_ix" at WLAN "wlan_ix" in channel "c"
                if PSI_cell{psi_ix}(wlan_ix, c) == 1    
                    intra_wlan_power = power_sta_from_ap(wlan_ix, wlan_ix) - 3 * (n_channels_used_for_tx-1);
                    interference_power = pow2db(db2pow(Power_STA_PSI_cell{psi_ix}(wlan_ix,c)));
                    SINR = compute_sinr(intra_wlan_power, interference_power, NOISE_DBM);        
                else                    
                    SINR = -Inf;                    
                end                 
                SINR_cell{psi_ix}(wlan_ix, c) = SINR;  
            end            
        end
    end    
end