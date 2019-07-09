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

%%% File description: script for generating the system configuration

path_loss_model = PATH_LOSS_AX_RESIDENTIAL;         % Path loss model index
access_protocol_type = ACCESS_PROTOCOL_SR_SINGLE_CHANNEL;   % Access protocol type
flag_hardcode_distances = false;                     % Allows hardcoding distances from main_sfctmn.m file
carrier_frequency = 5;                              % Carrier frequency [GHz] (2.4 or 5) GHz
NOISE_DBM = -95;                                    % Ambient noise [dBm]
BANDWITDH_PER_CHANNEL = 20e6;                       % Bandwidth per channel [MHz]
SINGLE_USER_SPATIAL_STREAMS = 1;                    % Number of spatial streams
IEEE_AX_MAX_PPDU_DURATION = 5484 * 0.000001;

% DSA policy type (SFCTMN)
dsa_policy_type = DSA_POLICY_ONLY_PRIMARY_SPATIAL_REUSE;
num_channels = 1;

save('configuration_system.mat');  % Save system configuration into current folder