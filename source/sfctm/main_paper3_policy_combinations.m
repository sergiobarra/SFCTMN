%%% *********************************************************************
%%% * Spatial-Flexible CTMN for WLANs                                   *
%%% * Author: Sergio Barrachina-Munoz (sergio.barrachina@upf.edu)       *
%%% * Copyright (C) 2017-2022, and GNU GPLd, by Sergio Barrachina-Munoz *
%%% * GitHub repository: https://github.com/sergiobarra/SFCTMN          *
%%% * More info on https://www.upf.edu/en/web/sergiobarrachina          *
%%% *********************************************************************

%%% File description: main script for running WLAN's CTMN analysis

clear
close all
clc

% Display framework header
type '..\..\sfctmn_header.txt'

%% FRAMEWORK CONFIGURATION
% Framework configuration. Booleans for activating specific functionalities

% - General settings
flag_save_console_logs = false;     % Flag for saving the console logs in a text file

% - Display
flag_display_PSI_states = false;     % Flag for displaying PSI's CTMC states
flag_display_S_states = false;       % Flag for displaying S' CTMC states
flag_display_wlans = false;         % Flag for displaying WLANs' input info
flag_display_Power_PSI = false;         % Flag for displaying sensed powers
flag_display_Q_logical = false;     % Flag for displaying logical transition rate matrix
flag_display_Q = false;              % Flag for displaying transition rate matrix
flag_display_throughput = true;     % Flag for displaying the throughput

% - Plots
flag_plot_PSI_ctmc = false;          % Flag for plotting PSI's CTMC
flag_plot_S_ctmc = false;           % Flag for plotting S' CTMC
flag_plot_wlans = true;            % Flag for plotting WLANs' distribution
flag_plot_ch_allocation = true;    % Flag for plotting WLANs' channel allocation
flag_plot_throughput = false;        % Flag for plotting the throughput

% - Logs
flag_logs_feasible_space = false;   % Flag for displaying logs of feasible space construction algorithm

if flag_save_console_logs
    diary('console_logs.txt') % Save logs in a text file
end

%% INPUT PROCESSING
%   - Load constant variables
%   - Load system configuration (e.g., path loss model, DSA policy, access
% protocol type, etc.)
%   - Check input correctness
%   - Display input (system and WLANs)

disp(' ')
disp('Setting framework up...')

% Framework constant variables
disp('- Loading constant variables...')
constants_script        % Execute constants_script.m script to store constants in the workspace
load('constants.mat');  % Load constants into workspace
disp([LOG_LVL3 'Constants loaded!'])

% System configuration
disp([LOG_LVL2 'Loading system configuration...'])
system_conf            % Execute system_conf.m script to store constants in the workspace
load('system_conf.mat');    % Load constants into workspace
disp([LOG_LVL3 'System configuration loaded!'])

% Get WLANs info from input CSV file
disp([LOG_LVL2 'Processing WLAN input...'])
filename = '../../input/wlans_input.csv';   % Path to WLAN input file
[wlans, num_channels_system, num_wlans] = generate_wlans(filename);

% HARDCODING distance for convenience
%  AP ---- AP ---- AP
%  |       |       |
% STA     STA     STA
%
if flag_hardcode_distances
    disp([LOG_LVL3 'HARDCODING DISTANCES FOR CONVENIENCE!'])
    distance_ap_sta = 1;
    distance_ap_ap = 200;
    for w = 1 : num_wlans
        wlans(w).position_ap = [((w - 1) * distance_ap_ap) 0 0];
        wlans(w).position_sta = wlans(w).position_ap + [0 -distance_ap_sta 0];
    end
end
% END OF HARDCODING distance for convenience

% Check input correctness
disp([LOG_LVL3 'Checking input configuration...'])
check_input_config(wlans);
disp([LOG_LVL4 'WLANs input file processed successfully!'])

% Display WLANs information
interest_power = compute_power_received(distance_ap_sta, POWER_TX_DEFAULT, GAIN_TX_DEFAULT,...
    GAIN_RX_DEFAULT, carrier_frequency, path_loss_model);

sinr_isolation = compute_sinr(interest_power, 0, NOISE_DBM);    % SINR sensed in the STA in isolation (just considering ambient noise)

display_wlans(wlans, flag_display_wlans, flag_plot_wlans, flag_plot_ch_allocation, num_channels_system,...
    path_loss_model, carrier_frequency, sinr_isolation)

% Display system configuration
disp([LOG_LVL2 'System configuration'])
disp([LOG_LVL3 'Access protocol: ' LABELS_DICTIONARY_ACCESS_PROTOCOL(access_protocol_type + 1,:)])
disp([LOG_LVL3 'Path loss model: ' LABELS_DICTIONARY_PATH_LOSS(path_loss_model,:)])
disp([LOG_LVL3 'Carrier frequency: ' num2str(carrier_frequency * 1e-9) ' GHz'])


%% GLOBAL STATES SPACE (PSI)
% - Identify global states space (PSI) according ONLY to medium access
% protocol constraints

disp(' ')
disp([LOG_LVL1 'Identifying global state space (PSI)...'])
[PSI_cell, num_global_states, PSI] = identify_global_states(wlans, num_channels_system, num_wlans, access_protocol_type);
disp([LOG_LVL2 'Global states identified! There are ' num2str(num_global_states) ' global states.'])

%% SENSED POWER
% Compute the power perceived by each WLAN in every channel in every global state [dBm]
disp(' ')
disp([LOG_LVL1 'Computing interference sensed power by the STAs in every state (Power_PSI). It may take some minutes :) ...'])
Power_PSI_cell = compute_sensed_power(wlans, num_global_states, num_channels_system, PSI_cell, path_loss_model,...
    carrier_frequency);
disp([LOG_LVL2 'Sensed power computed!'])

%% FEASIBLE STATES SPACE (S)
% Identify feasible states space (S) according to spatial and spectrum requirements.

% Sergio on 23/10/2017
% - Hardcoded for paper 3: finding scenario where WLANs have different optimal policies
% - There are 3 WLANs that can pick 4 policies (AM, SCB, OP, PU).
% - Therefore, there are 64 possible combinations

policies_by_wlan = [DSA_POLICY_AGGRESSIVE, DSA_POLICY_ONLY_MAX, DSA_POLICY_ONLY_PRIMARY, DSA_POLICY_EXPLORER_UNIFORM] ...
    .* ones(num_wlans,4);

switch num_wlans
    
    case 2
        dsa_policy_matrix = allcomb(policies_by_wlan(1,:), policies_by_wlan(2,:));
        
    case 3
        % dsa_policy_matrix = allcomb(policies_by_wlan(1,:), policies_by_wlan(2,:), policies_by_wlan(3,:));
        % dsa_policy_matrix = [DSA_POLICY_AGGRESSIVE, DSA_POLICY_AGGRESSIVE, DSA_POLICY_AGGRESSIVE];
        % dsa_policy_matrix = [DSA_POLICY_AGGRESSIVE, DSA_POLICY_EXPLORER_UNIFORM, DSA_POLICY_AGGRESSIVE];
        dsa_policy_matrix = [DSA_POLICY_EXPLORER_UNIFORM, DSA_POLICY_AGGRESSIVE, DSA_POLICY_EXPLORER_UNIFORM];
        % dsa_policy_matrix = [DSA_POLICY_EXPLORER_UNIFORM, DSA_POLICY_EXPLORER_UNIFORM, DSA_POLICY_EXPLORER_UNIFORM];
        % dsa_policy_matrix = [DSA_POLICY_AGGRESSIVE, DSA_POLICY_AGGRESSIVE, DSA_POLICY_EXPLORER_UNIFORM];
        % dsa_policy_matrix = [DSA_POLICY_AGGRESSIVE, DSA_POLICY_EXPLORER_UNIFORM, DSA_POLICY_EXPLORER_UNIFORM];
        
    case 4
        dsa_policy_matrix = allcomb(policies_by_wlan(1,:), policies_by_wlan(2,:), policies_by_wlan(3,:), policies_by_wlan(4,:));
        
    case 5
        dsa_policy_matrix = allcomb(policies_by_wlan(1,:), policies_by_wlan(2,:), policies_by_wlan(3,:), policies_by_wlan(4,:), policies_by_wlan(5,:));
        
end

throughput_by_policy_comb = zeros(size(dsa_policy_matrix,1),size(dsa_policy_matrix,2));
total_throughput_by_policy_comb = zeros(size(dsa_policy_matrix,1),1);
fairness_by_policy_comb = zeros(size(dsa_policy_matrix,1),1);

% For each possible combination of CB policies
for comb_ix = 1:size(dsa_policy_matrix,1)
    
    disp('***********************************************************************')
    disp(['Policy combination ' num2str(comb_ix) '/' num2str(size(dsa_policy_matrix,1)) ':'])
    disp(dsa_policy_matrix(comb_ix,:))
    
%     [ Q, S, S_cell, Q_logical_S, Q_logical_PSI, S_num_states ] = identify_feasible_states_and_Q(PSI_cell, Power_PSI_cell,...
%         num_channels_system, wlans, dsa_policy_type, flag_logs_feasible_space);

    dsa_policy_vector = dsa_policy_matrix(comb_ix,:);
    
     [ Q, S, S_cell, Q_logical_S, Q_logical_PSI, S_num_states ] = identify_feasible_states_and_Q_policy_comb(PSI_cell, Power_PSI_cell,...
        num_channels_system, wlans, dsa_policy_vector, flag_logs_feasible_space);
    
    %% MARKOV CHAIN
    % Solve Markov Chain from equilibrium distribution
    
    % Equilibrium distribution array (pi). Element s is the probability of being in state s.
    % - The left null space of Q is equivalent to solve [pi] * Q =  [0 0 ... 0 1]
    p_equilibrium = mrdivide([zeros(1,size(Q,1)) 1],[Q ones(size(Q,1),1)]);
    [Q_is_reversible, error_reversible] = isreversible(Q,p_equilibrium,1e-8); % Alessandro code for checking reversibility
    
    [prob_tx_num_channels_success, prob_tx_num_channels_unsuccess] = get_probability_tx_in_n_channels(Power_PSI_cell,...
        S_cell, PSI_cell, num_wlans, num_channels_system, p_equilibrium, path_loss_model, distance_ap_sta, wlans,...
        carrier_frequency);
    
    [prob_dominant, dominant_state_ix] = max(p_equilibrium);
    
    % get_throughput now per states
    throughput = get_throughput(prob_tx_num_channels_success, num_wlans, num_channels_system);
    
    throughput_by_policy_comb(comb_ix, :) = throughput';
    
    total_throughput_by_policy_comb(comb_ix) = sum(throughput);
    
    proportional_fairness = sum(log(throughput));
    
    fairness_by_policy_comb(comb_ix) = proportional_fairness;
    
    jains_fairness(comb_ix) = ((sum(throughput))^2) / (3 * sum(throughput.^2));
    
    
    %% Display info and plot
    
    disp(' ');
    
    % Display global states
    if flag_display_PSI_states
        disp(' ')
        disp([LOG_LVL2 'GLOBAL states (PSI):'])
        for s = 1 : length(PSI_cell)
            disp(['PSI(' num2str(s) ')']);
            disp(PSI_cell{s})
        end
        disp(' ')
        disp([LOG_LVL2 'PSI logical transition matrix (Q_logical_PSI)'])
        disp(Q_logical_PSI)
    end
    
    % Display sensed power in every global state
    if flag_display_Power_PSI
        disp(' ')
        for s = 1 : length(Power_PSI_cell)
            disp(['  - Power_PSI(' num2str(s) ')']);
            disp(Power_PSI_cell{s})
        end
    end
    
    % Display feasible states
    if flag_display_S_states
        disp(' ')
        disp([LOG_LVL2 'FEASIBLE states (S). Number of states :' num2str(S_num_states)])
        for s = 1 : length(S_cell)
            disp(['S(' num2str(s) ')']);
            disp(S_cell{s})
        end
    end
    
    % Display logical transition rate matrix
    if flag_display_Q_logical
        disp([LOG_LVL2 'Logical transition rate matrix in S (Q_logical_S):'])
        disp(Q_logical_S)
    end
    
    % Display transition rate matrix
    if flag_display_Q
        disp([LOG_LVL2 'Transition rate matrix in S (Q):'])
        disp(Q)
    end
    
    % Plot global state space CTMC
    if flag_plot_PSI_ctmc
        disp([LOG_LVL2 'Plotting PSI CTMC...'])
        plot_ctmc(PSI, num_wlans, num_channels_system, 'CTMC of global (PSI) and feasible (S) states', Q_logical_PSI);
        disp([LOG_LVL3 'Plotted!'])
    end
    
    % Plot feasible state space CTMC
    if comb_ix == 1
        disp([LOG_LVL2 'Plotting S CTMC...'])
        plot_ctmc(S , num_wlans, num_channels_system, 'CTMC of feasible states (S)', Q_logical_S);
        disp([LOG_LVL3 'Plotted!'])
    end
    
    % Display throughput
    if flag_display_throughput
        disp([LOG_LVL2 'Throughput [Mbps]:']);
        for w = 1 : num_wlans
            disp([LOG_LVL4 LABELS_DICTIONARY(w) ': ' num2str(throughput(w))]);
        end
        disp(throughput)
        disp([LOG_LVL3 'Total: ' num2str(sum(throughput))]);
        disp([LOG_LVL3 'Proportional fairness: ' num2str(proportional_fairness)]);
        disp([LOG_LVL3 'Jains fairness index: ' num2str(jains_fairness)]);
    end
    
end

%% FIND OPTIMAL POLICY 
% 
% [max_through, ix_throughput] = max(total_throughput_by_policy_comb);
% 
% [max_fair, ix_fair] = max(fairness_by_policy_comb);
% 
% 
% disp('MOST THROUGHPUT COMBINATION: ')
% for wlan_ix = 1:num_wlans
%     disp([LOG_LVL4 LABELS_DICTIONARY(wlan_ix) ': ' ...
%         LABELS_DICTIONARY_DSA_POLICY(dsa_policy_matrix(ix_throughput,wlan_ix),:)]);      
% end
% disp(' - Throughput: ')
% disp(throughput_by_policy_comb(ix_throughput,:))
% 
% disp('    * Compared with throughput in all Always-Max: ')
% disp(throughput_by_policy_comb(1,:))
% 
% disp('MOST FAIR COMBINATION: ')
% for wlan_ix = 1:num_wlans
%     disp([LOG_LVL4 LABELS_DICTIONARY(wlan_ix) ': ' ...
%         LABELS_DICTIONARY_DSA_POLICY(dsa_policy_matrix(ix_fair,wlan_ix),:)]);      
% end
% 
% disp([' - Fairness: '])
% disp(fairness_by_policy_comb(ix_fair))
% 
% disp([LOG_LVL3 'Jains fairness index: ' num2str(jains_fairness)]);
% 
% disp(' - Compare with fairness in in all Always-Max: ')
% disp(fairness_by_policy_comb(1))

disp([LOG_LVL1 'Finished!'])