%%% *********************************************************************
%%% * Spatial-Flexible CTMN for WLANs                                   *
%%% * Author: Sergio Barrachina-Munoz (sergio.barrachina@upf.edu)       *
%%% * Copyright (C) 2017-2022, and GNU GPLd, by Sergio Barrachina-Munoz *
%%% * GitHub repository: https://github.com/sergiobarra/SFCTMN          *
%%% * More info on https://www.upf.edu/en/web/sergiobarrachina          *
%%% *********************************************************************

function [ Power_AP_PSI_cell, Power_STA_PSI_cell, SINR_cell, Tx_Power_Linear_PSI_cell, ... 
    Power_Detection_PSI_cell, Interest_Power_PSI_cell, Individual_Power_AP_PSI_cell] = ...
    compute_sensed_power( wlans, num_global_states, PSI_cell, path_loss_model, carrier_frequency, num_channels_system)
    
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
    
    num_wlans = length(wlans);  % Number of WLANs
    [distance_ap_ap, distance_ap_sta] = compute_distance_nodes(wlans); % distances between APs and STAs
    
    % Initialize and declare arrays and structures to be used    
    % - Variables STEP 1
    power_restriction_activated = cell(1,num_global_states);    % Indicates, for each state, whether a given WLAN is under power restriction    
    Power_Detection_PSI_cell = cell(1,num_global_states);       % Set of power detection thresholds that each WLAN uses in each state (several possibilities per state)
    % - Variables STEP 2
    Tx_Power_Linear_PSI_cell = cell(1,num_global_states);       % Set of transmit power that each AP uses in each state. Item {s}(w) is the transmit power used by AP in WLAN w in state s.
    Power_AP_PSI_cell = cell(1,num_global_states);              % Set of powers [dBm] sensed in the AP in cell array form. Item {s}(w,c) is the power sensed by AP in WLAN w in channel c in state s.
    P_AP_PSI_linear_cell = cell(1,num_global_states);           % P_PSI_cell with linear powers (for convenience when summing)  
    Power_STA_PSI_cell = cell(1,num_global_states);             % Set of powers [dBm] sensed in the STA in cell array form. Item {s}(w,c) is the power sensed by STA in WLAN w in channel c in state s.
    P_STA_PSI_linear_cell = cell(1,num_global_states);
    Individual_Power_AP_PSI_cell = cell(1,num_global_states);
    % - Variables STEP 3
    Interest_Power_PSI_cell = cell(1,num_global_states);        % Power of interest of each WLAN in each state
    SINR_cell = cell(1,num_global_states);                      % Set of SINR [dBm] in cell array form. Item {s}(w,c) is the SINR in STA of WLAN w in channel c in state s.
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%        
    % STEP 1 - DETERMINE THE POWER DETECTION THRESHOLD AND THE TRANSMIT POWER 
    %   USED BY EACH WLAN IN EACH STATE, ACCORDING TO SR OPERATION   
    % Iterate for each global state
    for psi_ix = 1 : num_global_states
        % Initialize the power_restriction_activated array for state psi_ix
        power_restriction_activated{psi_ix} = -Inf * ones(1, num_wlans); 
        % In case of observing an SR state, 2 different PD thresholds can be used (non-SRG and SRG)
        power_detection_threshold = -Inf*ones(1, num_wlans);
        num_channels = 1;
        tx_power = zeros(1, num_wlans);
        % Store the possible PD values for each WLAN
        for wlan_ix = 1 : num_wlans     
            if PSI_cell{psi_ix}(wlan_ix) == STATE_DEFAULT
                power_detection_threshold(wlan_ix) = wlans(wlan_ix).cca;
            elseif PSI_cell{psi_ix}(wlan_ix) == STATE_NONSRG_ACTIVATED
                % Activate power restriction mode
                power_restriction_activated{psi_ix}(wlan_ix) = 1;
                power_detection_threshold(wlan_ix) = wlans(wlan_ix).non_srg_obss_pd;
            elseif PSI_cell{psi_ix}(wlan_ix) == STATE_SRG_ACTIVATED
                % Activate power restriction mode
                power_restriction_activated{psi_ix}(wlan_ix) = 1;
                power_detection_threshold(wlan_ix) = wlans(wlan_ix).srg_obss_pd;
            end   
            % Determine the transmit power used in each state
            tx_power(wlan_ix) = min(TX_POWER_MAX, wlans(wlan_ix).tx_power - 3 * (num_channels - 1));
            if power_restriction_activated{psi_ix}(wlan_ix) == 1
                % - Apply power restriction
                tx_power_max = min(TX_POWER_MAX , wlans(wlan_ix).tx_pwr_ref ...
                    - (power_detection_threshold(wlan_ix) - OBSS_PD_MIN) - 3 * (num_channels - 1));  
                if tx_power_max < tx_power(wlan_ix)
                    tx_power(wlan_ix) = tx_power_max;
                end  
            end
        end        
        % Fill the objects containing the PD and the TX Power used in each state
        Power_Detection_PSI_cell{psi_ix} = power_detection_threshold;    
        Tx_Power_Linear_PSI_cell{psi_ix} = db2pow(tx_power);
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%        
    % STEP 2 - DETERMINE THE POWER RECEIVED AT EACH WLAN IN EACH STATE, ACCORDING TO SR OPERATION
    % Iterate for each global state
    for psi_ix = 1 : num_global_states    
        Individual_Power_AP_PSI_cell{psi_ix} = -Inf*ones(num_wlans, num_wlans);
        % Iterate for each WLAN
        for wlan_ix = 1 : num_wlans                                                                
            sum_power_rx_ap_linear = 0; %zeros(1,3);    % Array to store all the possible values of total rx power in each AP
            sum_power_rx_sta_linear = 0; %zeros(1,3);   % Array to store all the possible values of total rx power in each STA
            % Iterate for each WLAN (potential transmitters)
            for wlan_ix_aux = 1 : num_wlans         
                % Check if WLAN wlan_ix_aux is transmitting in state psi_ix
                if PSI_cell{psi_ix}(wlan_ix_aux) > 0 
                    if wlan_ix ~= wlan_ix_aux
                        distance_w_ap = distance_ap_ap(wlan_ix, wlan_ix_aux);     % Distance between the AP of wlan_ix and the AP of w_aux
                        distance_w_sta = distance_ap_sta(wlan_ix_aux, wlan_ix);   % Distance between the AP of w_aux and the STA of wlan_ix
                        % Compute the power received in each STA from each AP
                        power_rx_sta_dbm = compute_power_received(distance_w_sta, pow2db(Tx_Power_Linear_PSI_cell{psi_ix}(wlan_ix_aux)), ...
                            GAIN_TX_DEFAULT, GAIN_RX_DEFAULT, carrier_frequency, path_loss_model);  
                        %powerRxStationFromApLinear(wlan_ix, w_aux) = db2pow(power_rx_sta_dbm);     
                        sum_power_rx_sta_linear = sum_power_rx_sta_linear + db2pow(power_rx_sta_dbm);  
                        % Compute the power received in each AP from each AP
                        power_rx_ap_dbm = compute_power_received(distance_w_ap, pow2db(Tx_Power_Linear_PSI_cell{psi_ix}(wlan_ix_aux)), ...
                            GAIN_TX_DEFAULT, GAIN_RX_DEFAULT, carrier_frequency, path_loss_model);  
                        % Update the individual power sensed from each AP
                        Individual_Power_AP_PSI_cell{psi_ix}(wlan_ix, wlan_ix_aux) = power_rx_ap_dbm;
                        % Increase the additive interefence sensed in WLAN wlan_ix
                        sum_power_rx_ap_linear = sum_power_rx_ap_linear + db2pow(power_rx_ap_dbm); 
                    end                    
                end
            end
            % Power received at the AP
            P_AP_PSI_linear_cell{psi_ix}(wlan_ix) = sum_power_rx_ap_linear;
            Power_AP_PSI_cell{psi_ix}(wlan_ix) = pow2db(P_AP_PSI_linear_cell{psi_ix}(wlan_ix));
            % Power received at the STA
            P_STA_PSI_linear_cell{psi_ix}(wlan_ix) = sum_power_rx_sta_linear;
            Power_STA_PSI_cell{psi_ix}(wlan_ix) = pow2db(P_STA_PSI_linear_cell{psi_ix}(wlan_ix));              
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%        
        % STEP 3 - DETERMINE THE SINR OF EACH WLAN IN EACH STATE
        Interest_Power_PSI_cell{psi_ix} = zeros(num_wlans, num_channels_system);
        for wlan_ix = 1 : num_wlans            
            n_channels_used_for_tx = 1;
            % Compute the SINR for state "psi_ix" at WLAN "wlan_ix" in channel "c"
            if PSI_cell{psi_ix}(wlan_ix) > 0                        
                Interest_Power_PSI_cell{psi_ix}(wlan_ix) = ...
                compute_power_received(distance_ap_sta(wlan_ix, wlan_ix), ...
                    pow2db(Tx_Power_Linear_PSI_cell{psi_ix}(wlan_ix)), ...
                    GAIN_TX_DEFAULT, GAIN_RX_DEFAULT, carrier_frequency, path_loss_model);   
            else                    
                 Interest_Power_PSI_cell{psi_ix}(wlan_ix) = -Inf;
            end
            %Interest_Power_PSI_cell{psi_ix} = power_sta_from_ap;
            intra_wlan_power = Interest_Power_PSI_cell{psi_ix}(wlan_ix) - 3 * (n_channels_used_for_tx-1);
            interference_power = pow2db(db2pow(Power_STA_PSI_cell{psi_ix}(wlan_ix)));
            SINR_cell{psi_ix}(wlan_ix) = compute_sinr(intra_wlan_power, interference_power, NOISE_DBM);
%             disp(['wlan ' num2str(wlan_ix) ' in state ' num2str(psi_ix) '(' num2str(PSI_cell{psi_ix}(wlan_ix)) '):' ])
%             disp(['  * transmit power: ' num2str(pow2db(Tx_Power_Linear_PSI_cell{psi_ix}(wlan_ix)))])
%             disp(['  * interest power: ' num2str(Interest_Power_PSI_cell{psi_ix}(wlan_ix))])
%             disp(['  * intra_wlan_power: ' num2str(intra_wlan_power)])
%             disp(['  * interference_power: ' num2str(interference_power)])
%             disp(['  * SINR: ' num2str(SINR)])
                        
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    end 
    
end