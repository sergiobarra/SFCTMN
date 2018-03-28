%%% *********************************************************************
%%% * Spatial-Flexible CTMN for WLANs                                   *
%%% * Author: Sergio Barrachina-Munoz (sergio.barrachina@upf.edu)       *
%%% * Copyright (C) 2017-2022, and GNU GPLd, by Sergio Barrachina-Munoz *
%%% * GitHub repository: https://github.com/sergiobarra/SFCTMN          *
%%% * More info on https://www.upf.edu/en/web/sergiobarrachina          *
%%% *********************************************************************

%%% File description: script for generating the system configuration

% Throughput
PACKET_ERR_PROBABILITY = 0.0;                   % Packet error probability
NUM_PACKETS_AGGREGATED = 1;                     % Number of aggregated packets in each transmission
PACKET_LENGTH = 12000;                          % Packet length [bits]
SINGLE_USER_SPATIAL_STREAMS = 1;                % Single User Spatial Streams
MCS_INDEX = 11;                                 % Modulation Coding Scheme index

% Power
CCA_DEFAULT = -82;                              % CCA level [dBm]
CAPTURE_EFFECT = 10;                            % Capture effect [dB]
POWER_TX_DEFAULT = 20;                          % Transmission power [dBm]
GAIN_TX_DEFAULT = 0;                            % Transmitter gain [dB]
GAIN_RX_DEFAULT = 0;                            % Receiver gain [dB]
CHANNEL_WIDTH_MHz = 20;

path_loss_model = PATH_LOSS_WMN_SEMINAR;            % Path loss model index
access_protocol_type = ACCESS_PROTOCOL_IEEE80211;   % Access protocol type
flag_hardcode_distances = false;                    % Allows hardcoding distances from main_sfctmn.m file
carrier_frequency = 5E9;                            % Carrier frequency [MHz] (2.4 or 5) GHz
NOISE_DBM = -95;                                    % Ambient noise [dBm]

% DSA policy type
dsa_policy_type = DSA_POLICY_ONLY_MAX;          % Always-max

save('system_conf.mat');  % Save system configuration into current folder
disp('System configuration saved in file system_conf.mat')