%%% * Spatial-Flexible CTMN for WLANs                                   *
%%% * Author: Sergio Barrachina-Munoz (sergio.barrachina@upf.edu)       *
%%% * Copyright (C) 2017-2022, and GNU GPLd, by Sergio Barrachina-Munoz *
%%% * GitHub repository: https://github.com/sergiobarra/SFCTMN          *
%%% * More info on https://www.upf.edu/en/web/sergiobarrachina          *
%%% *********************************************************************

%%% File description: main script for running WLAN's CTMC analysis with several dsa_policies in one script
%%% Status: working on it

clear
close all
clc

%% System config

disp('**********************')
disp('* WLAN CTMC ANALYSIS *')
disp('**********************')
disp(' ')
disp('Loading constant variables...')
constants_script      % Execute constant variables.m script to store constants in the workspace
load('constants.mat');  % Load constants into workspace
disp('  - Constants loaded!')

% Flags: booleans for activating specific functionalities
% - General settings
flag_save_console_logs = false;     % Flag for saving the console logs in a text file
% - Display
flag_display_PSI_states = false;     % Flag for displaying PSI's CTMC states
flag_display_S_states = false;       % Flag for displaying S' CTMC states
flag_display_wlans = true;         % Flag for displaying WLANs' input info
flag_display_Power_PSI = false;         % Flag for displaying sensed powers
flag_display_Q_logical = false;     % Flag for displaying logical transition rate matrix 
flag_display_Q = false;              % Flag for displaying transition rate matrix
flag_display_throughput = true;     % Flag for displaying the throughput
% - Plots
flag_plot_PSI_ctmc = false;          % Flag for plotting PSI's CTMC
flag_plot_S_ctmc = false;           % Flag for plotting S' CTMC
flag_plot_wlans = false;            % Flag for plotting WLANs' distribution
flag_plot_ch_allocation = false;    % Flag for plotting WLANs' channel allocation
flag_plot_throughput = true;        % Flag for plotting the throughput
% - Logs
flag_logs_feasible_space = false;   % Flag for displaying logs of feasible space construction algorithm
% System configuration
access_protocol_type = ACCESS_PROTOCOL_IEEE80211;


% dsa_policy_type = DSA_POLICY_AGGRESSIVE;
% dsa_policy_type = DSA_POLICY_ONLY_MAX;
% dsa_policy_type = DSA_POLICY_EXPLORER_UNIFORM;
% dsa_policy_type = DSA_POLICY_EXPLORER_LADDER;

if flag_save_console_logs
    diary('console_logs.txt') % Save logs in a text file
end

%% Process input
% Get WLANs info from input CSV file

disp('Processing input CSV...')
filename = 'wlans_input.csv';   % Path to input file
input_data = load(filename);            

% Generate wlan structures
wlans = []; % Array of structures containning wlans info
num_wlans = length(input_data(:,1));    % Number of WLANs (APs)
num_channels_system = 0;                % Number of channels in the system (is determined the most right channel used)

for w = 1 : num_wlans
    
    wlans(w).code = input_data(w,INPUT_FIELD_IX_CODE);          % Pick WLAN code
    wlans(w).primary = input_data(w,INPUT_FIELD_PRIMARY_CH);    % Pick primary channel
    wlans(w).range = [input_data(w,INPUT_FIELD_LEFT_CH) input_data(w,INPUT_FIELD_RIGHT_CH)];  % pick range
    wlans(w).num_nodes = input_data(w,INPUT_FIELD_NUM_NODES);   % Pick number of nodes
    wlans(w).position = [input_data(w,INPUT_FIELD_POS_X) input_data(w,INPUT_FIELD_POS_Y)...
        input_data(w,INPUT_FIELD_POS_Z)];                       % Pick positions
    wlans(w).tx_power = input_data(w,INPUT_FIELD_TX_POWER);     % Pick transmission power
    wlans(w).cca = input_data(w,INPUT_FIELD_CCA);               % Pick CCA level
    wlans(w).lambda = input_data(w,INPUT_FIELD_LAMBDA);         % Pick lambda
    wlans(w).states = [];   % Instantiate states for later use          
    wlans(w).widths = [];   % Instantiate acceptable widhts item for later use
    
    if(num_channels_system <  wlans(w).range(2))
        num_channels_system = wlans(w).range(2);         % update number of channels present in the system
    end

end

d_AP = [10 500 1500];

for d_ix = 1 : length(d_AP)
    
    disp('-------------------------------------------------------------------------------------------------------')
    disp(' ')
    disp(['********** DISTANCE: ' num2str(d_AP(d_ix))])
        
    for w = 1 : num_wlans
        wlans(w).position = [((w - 1) * d_AP(d_ix)) 0 0];
    end

    disp('  - Checking input configuration...')

    check_input_config(wlans);

    disp('  - Input file processed successfully!')

    display_wlans(wlans, flag_display_wlans, flag_plot_wlans, flag_plot_ch_allocation, num_channels_system)

    disp('System configuration')
    disp([' - Access protocol: ' LABELS_DICTIONARY_ACCESS_PROTOCOL(access_protocol_type + 1,:)])
    disp(' - DSA policy: VARIABLE')

    %% Global states
    % Identify global states (PSI) according medium access protocol requirements

    disp(' ')
    disp('Identifying global state space (PSI)...')
    [PSI_cell, num_global_states, PSI] = identify_global_states(wlans, num_channels_system, num_wlans, access_protocol_type);
    disp([' - Global states identified! There are ' num2str(num_global_states) ' global states.'])

    %% Sensed power
    % Compute the power perceived by each WLAN in every channel in every global state [dBm]

    disp(' ')
    disp('Computing sensed powers (Power_PSI). It may take some minutes :) ...')
    Power_PSI_cell = compute_sensed_power( wlans, num_global_states, num_channels_system, PSI_cell );
    disp(' - Sensed power computed!')


    %% FOR SEVERAL DSA POLICIES

    for dsa_policy_type = 1 : size(LABELS_DICTIONARY_DSA_POLICY,1)

        disp(' ')
        disp(' ')
        disp(['**** DSA policy: ' LABELS_DICTIONARY_DSA_POLICY(dsa_policy_type,:)])

        %% Feasible states
        % Identify feasible states (S) according to spatial and spectrum conditions.
        disp(' ')
        disp('Identifying feasible state space (S) and transition rate matrix (Q)...')
        [ Q, S, S_cell, Q_logical_S, Q_logical_PSI, S_num_states ] = identify_feasible_states_and_Q(PSI_cell, Power_PSI_cell,...
            num_channels_system, wlans, dsa_policy_type, flag_logs_feasible_space);

        disp([' - Feasible state space (S) identified! There are ' num2str(S_num_states) ' feasible states.'])

        %% Equilibrium distribution
        % Solve Markov Chain

        disp(' ')
        disp('Solving pi * Q = 0 ...')

        % Equilibrium distribution array (pi). Element s is the probability of being in state s.
        % - The left null space of Q is equivalent to solve [pi] * Q =  [0 0 ... 0 1]
        p_equilibrium = mrdivide([zeros(1,size(Q,1)) 1],[Q ones(size(Q,1),1)]);
        [Q_is_reversible, error_reversible] = isreversible(Q,p_equilibrium,1e-8); % Alessandro code for checking reversibility

        disp('  - Equilibrium distribution found! Prob. of being in each possible state:')
        disp(p_equilibrium)
        disp(['  - Reversible Markov chain? ' num2str(Q_is_reversible) ' (error: ' num2str(error_reversible) ')'])

        prob_tx_in_num_channels = get_probability_tx_in_n_channels(S_cell, num_wlans, num_channels_system, p_equilibrium); 
        disp('  - Probability of transmitting in num channels (0:num_channels_system): ')
        disp(prob_tx_in_num_channels)

        [prob_dominant, dominant_state_ix] = max(p_equilibrium);
        disp(['  - Dominant state: s' num2str(dominant_state_ix) ' (with probability ' num2str(prob_dominant) ')'])

        disp(' ')
        disp('Computing throughput...')
        throughput = get_throughput(prob_tx_in_num_channels, num_wlans, num_channels_system);
        proportional_fairness = sum(log(throughput));
        disp('  - Trhoughput computed!')


        %% Display info and plot

        disp(' ');
        disp(' ');
        disp('***** RESULTS *****');

        % Display global states
        if flag_display_PSI_states
            disp(' ')
            disp(' - GLOBAL states (PSI):');
            for s = 1 : length(PSI_cell)
                disp(['PSI(' num2str(s) ')']);
                disp(PSI_cell{s})
            end
            disp(' ')
            disp('PSI logical transition matrix (Q_logical_PSI)')
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
            disp([' - FEASIBLE states (S). Number of states :' num2str(S_num_states)])
            for s = 1 : length(S_cell)
                disp(['S(' num2str(s) ')']);
                disp(S_cell{s})
            end
        end

        % Display logical transition rate matrix
        if flag_display_Q_logical
            disp(' - Logical transition rate matrix in S (Q_logical_S):')
            disp(Q_logical_S)
        end

        % Display transition rate matrix
        if flag_display_Q
            disp('  - Transition rate matrix in S (Q):')
            disp(Q)
        end

        % Plot global state space CTMC
        if flag_plot_PSI_ctmc
            disp('  - Plotting PSI CTMC...')
            plot_ctmc(PSI, num_wlans, num_channels_system, 'CTMC of global (PSI) and feasible (S) states', Q_logical_PSI);
            disp('    � Plotted!')
        end

        % Plot feasible state space CTMC
        if flag_plot_S_ctmc
            disp('  - Plotting S CTMC...')
            plot_ctmc(S , num_wlans, num_channels_system, LABELS_DICTIONARY_DSA_POLICY(dsa_policy_type), Q_logical_S);
            disp('    � Plotted!')
        end

        % Display throughput
        if flag_display_throughput
            disp('  - Throughput [Mbps]');
            for w = 1 : num_wlans
                disp(['    � ' LABELS_DICTIONARY(w) ': ' num2str(throughput(w))]);        
            end
            disp(['    � Total: ' num2str(sum(throughput))]);
            disp(['    � Proportional fairness: ' num2str(proportional_fairness)]);
        end

        if flag_plot_throughput
            plot_throughput(throughput, num_wlans, LABELS_DICTIONARY_DSA_POLICY(dsa_policy_type, :));
        end
    end
    
    
end




%% Save results
disp('--------------------------------------------------------')
disp('Finished!')