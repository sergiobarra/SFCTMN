%%% WLAN CTMC Analysis
%%% Author: Sergio Barrachina (sergio.barrachina@upf.edu)
%%% File description: function for computing the sensed power of each WLAN in every channel in every global state.

function [ Power_PSI_cell ] = compute_sensed_power( wlans, num_global_states, num_channels_system, PSI_cell,...
        path_loss_model)
    %COMPUTE_SENSED_POWER computes the sensed power of each WLAN in every channel in every global state. 
    % Input:
    %   - wlans: array of structures with wlans info
    %   - num_global_states: number of global states
    %   - num_channels_system:  number of channels in the system
    %   - PSI_cell: set of global states in cell array form
    %   - path_loss_model: path loss model
    %   - d_sta: distance between AP and STAs inside the same WLAN
    
    load('constants.mat');  % Load constants into local workspace
    
    % Set of powers [dBm] sensed in cell array form. Item {s}(w,c) is the power sensed by WLAN w in channel c in state s.
    Power_PSI_cell = {};
    P_PSI_linear_cell = {};     % P_PSI_cell with linear powers (for convenience when summing)
    
    num_wlans = length(wlans);  % Number of WLANs
    
    log_k = round(num_global_states/10);    % Auxiliar variable for displaying execution evolution in the terminal
    
    for psi_ix = 1 : num_global_states
        
        % Display evolution in command line
        if mod(psi_ix, log_k) == 0
             disp(['   � ' num2str(round(psi_ix*100/num_global_states)) ' %'])
        end
       
        for wlan_ix = 1 : num_wlans
            
            for c = 1 : num_channels_system
                
                sum_power_rx_linear = 0;
                
                for w_aux = 1 : num_wlans
                    
                    if wlan_ix ~= w_aux
                        
                        if PSI_cell{psi_ix}(w_aux,c) % If wlan_aux transmitting in state s
                            
                            distance_w_waux = pdist([wlans(wlan_ix).position(1) wlans(wlan_ix).position(2);...
                                wlans(w_aux).position(1) wlans(w_aux).position(2)] ,'euclidean');
                            
                            % Transmission power must be divided by the number of channels 
                            [~, ~, ~, num_channels, ~] = get_channel_range( PSI_cell{psi_ix}(w_aux,:) );
                            tx_power = wlans(w_aux).tx_power - 3*(num_channels - 1);    % 3dB less

                            pw_rx_dBm = compute_power_received(distance_w_waux, tx_power,...
                                GAIN_TX_DEFAULT, GAIN_RX_DEFAULT, FREQUENCY, path_loss_model);
                            
                            pw_rx_linear = 10^(pw_rx_dBm/10);
                            sum_power_rx_linear = sum_power_rx_linear + pw_rx_linear;
                            
                        end
                    end
                end
                P_PSI_linear_cell{psi_ix}(wlan_ix,c) = sum_power_rx_linear;
                Power_PSI_cell{psi_ix}(wlan_ix,c) = 10 * log10(P_PSI_linear_cell{psi_ix}(wlan_ix,c));
            end
        end
    end
    
end
