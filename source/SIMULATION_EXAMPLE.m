%%% ***********************************************************************
%%% *                                                                     *
%%% *             Spatial Reuse Operation in IEEE 802.11ax:               *
%%% *          Analysis, Challenges and Research Opportunities            *
%%% *                                                                     *
%%% * Submission to IEEE Surveys & Tutorials                              *
%%% *                                                                     *
%%% * Authors:                                                            *
%%% *   - Francesc Wilhelmi (francisco.wilhelmi@upf.edu)                  *
%%% *   - Sergio Barrachina-Muñoz  (sergio.barrachina@upf.edu)            *
%%% *   - Boris Bellalta (boris.bellalta@upf.edu)                         *
%%% *   - Cristina Cano (ccanobs@uoc.edu)                                 *
%%% * 	- Ioannis Selinis (ioannis.selinis@surrey.ac.uk)                  *
%%% *                                                                     *
%%% * Copyright (C) 2019-2024, and GNU GPLd, by Francesc Wilhelmi         *
%%% *                                                                     *
%%% * Repository:                                                         *
%%% *  https://github.com/fwilhelmi/tutorial_11ax_spatial_reuse           *
%%% ***********************************************************************

%% PART 1 - Generate the data
clear
clc

% Generate constants 
constants_sfctmn_framework
% Set specific configurations
configuration_system        

% Generate wlans object according to the input file
input_file = 'input_example_spatial_reuse.csv';
wlans = generate_wlan_from_file(input_file, false, false, 1, [], []);

% Compute the throughput of the scenario, for each OBSS_PD value
disp('---------------------------')
disp([' OBSS/PD (WLAN A) = -78 dBm / Tx Power (WLAN A) = 20 dBm'])  
disp('---------------------------')
% Set the OBSS_PD to be used by WLAN A
wlans(1).non_srg_obss_pd = -78;
% Call the SFCTMN framework
[throughput] = function_main_sfctmn(wlans);    
disp(['Throughput WLAN A in Test scenario: ' num2str(throughput(1))])
disp(['Throughput WLAN B in Test scenario: ' num2str(throughput(2))])