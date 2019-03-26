%%% *********************************************************************
%%% * Spatial-Flexible CTMN for WLANs                                   *
%%% * Author: Sergio Barrachina-Munoz (sergio.barrachina@upf.edu)       *
%%% * Copyright (C) 2017-2022, and GNU GPLd, by Sergio Barrachina-Munoz *
%%% * GitHub repository: https://github.com/sergiobarra/SFCTMN          *
%%% * More info on https://www.upf.edu/en/web/sergiobarrachina          *
%%% *********************************************************************

%%% File description: script for generating the constant variables

% Framework configuration. Booleans for activating specific functionalities

% - General settings
flag_save_console_logs = true;     % Flag for saving the console logs in a text file
flag_save_results = false;     % Flag for saving the results

% - General logs
flag_general_logs = true;

% - Display
flag_display_PSI_states = true;    % Flag for displaying PSI's CTMC states
flag_display_S_states = true;      % Flag for displaying S' CTMC states
flag_display_wlans = true;         % Flag for displaying WLANs' input info
flag_display_Power_PSI = false;     % Flag for displaying sensed powers
flag_display_Q_logical = false;     % Flag for displaying logical transition rate matrix 
flag_display_Q = false;             % Flag for displaying transition rate matrix
flag_display_throughput = false;    % Flag for displaying the throughput

% - Plots
flag_plot_PSI_ctmc = true;         % Flag for plotting PSI's CTMC
flag_plot_S_ctmc = true;           % Flag for plotting S' CTMC
flag_plot_wlans = true;            % Flag for plotting WLANs' distribution
flag_plot_ch_allocation = true;    % Flag for plotting WLANs' channel allocation
flag_plot_throughput = true;       % Flag for plotting the throughput

% - Logs
flag_logs_feasible_space = false;   % Flag for displaying logs of feasible space construction algorithm

% - Input checker
flag_input_checker = false;     % Flag for checking the input data

% Log layers for displaying purposes
LOG_LVL1 = '';
LOG_LVL2 = '- ';
LOG_LVL3 = '   + ';
LOG_LVL4 = '     - ';
LOG_LVL5 = '        + ';
LOG_LVL6 = '          - ';

% Input csv file indeces
INPUT_FIELD_IX_CODE = 1;                        % Index of code in the input file
INPUT_FIELD_PRIMARY_CH = 2;                     % Index of primary channel in the input file
INPUT_FIELD_LEFT_CH = 3;                        % Index of left channel in the input file
INPUT_FIELD_RIGHT_CH = 4;                       % Index of right channel in the input file
INPUT_FIELD_TX_POWER = 5;                       % Index of transmission power
INPUT_FIELD_CCA = 6;                            % Index of the CCA
INPUT_FIELD_LAMBDA = 7;                         % Index of lambda in the input file
INPUT_FIELD_POS_AP_X = 8;                       % Index of pos X in the input file
INPUT_FIELD_POS_AP_Y = 9;                       % Index of pos Y in the input file
INPUT_FIELD_POS_AP_Z = 10;                      % Index of pos Z in the input file
INPUT_FIELD_POS_STA_X = 11;                     % Index of pos X in the input file
INPUT_FIELD_POS_STA_Y = 12;                     % Index of pos Y in the input file
INPUT_FIELD_POS_STA_Z = 13;                     % Index of pos Z in the input file
INPUT_FIELD_LEGACY = 14;                        % Index of legacy field in the input file
INPUT_FIELD_CW = 15;                            % Index of the maximum Contention Window value
INPUT_FIELD_NON_SRG_ACTIVATED = 16;             % Index of non-SRG operation activation flag
INPUT_FIELD_SRG = 17;                           % Index of the SRG
INPUT_FIELD_NON_SRG_OBSS_PD = 18;               % Index of the non-SRG OBSS_PD
INPUT_FIELD_SRG_OBSS_PD = 19;                   % Index of the SRG OBSS_PD
INPUT_FIELD_TX_PWR_REF = 20;                    % Index of the TX PWR REF

% Labels
LABELS_DICTIONARY_PATH_LOSS = ['Free Space ';'Urban Macro';'Urban Pico ';'In-door sh.';'8011ax Res.';'5G Office  '];
LABELS_DICTIONARY_ACCESS_PROTOCOL = ['Log2maps';'Adjacent';'IE802.11';'SRSINGLE'];
LABELS_DICTIONARY_DSA_POLICY = ['Aggressive';'OnlyMax   ';'ExplorerUn';'ExplorerLa';'OnlyPri   ';'OnlyPriSR '];

% CTMC
FORWARD_TRANSITION = 1;                         % CTMC forward transition
BACKWARD_TRANSITION = 2;                        % CTMC backward transition
ACCESS_PROTOCOL_LOG2 = 0;                       % Log2 mapping channel access protocol
ACCESS_PROTOCOL_ADJACENT = 1;                   % Continuous mapping channel access protocol
ACCESS_PROTOCOL_IEEE80211 = 2;                  % IEEE 802.11 channel access protocol
ACCESS_PROTOCOL_SR_SINGLE_CHANNEL = 3;          % SR single channel access protocol
LABELS_DICTIONARY = ['A';'B';'C';'D';'E';'F';'G';'H';'I';'K'];  % Encoding of WLAN labels. From code to label (e.g. 2 --> B)
COLORS_DICTIONARY = [.9 .9 0; .9 0 .9; 0 .9 .9; .9 0 0;...
    0 .9 0; 0 0 .9; .5 .5 .5; .2 .5 .2; .9 .5 .1; .1 .5 .9];  % Encoding of colors

MU = [81.5727 150.8068 0 215.7497 0 0 0 284.1716];  % Packet departure rate depending on the number of channels (1, 2, 3, ..., 8)

% DCB policies
DSA_POLICY_AGGRESSIVE = 1;                      % DCB policy for picking always the maximum channel width available
DSA_POLICY_ONLY_MAX = 2;                        % DCB policy for picking only the whole available range when possible
DSA_POLICY_EXPLORER_UNIFORM = 3;                % DCB policy for picking one of the ranges found free uniformly
DSA_POLICY_EXPLORER_LADDER = 4;                 % DCB policy for picking one of the range found free depending on weights
DSA_POLICY_ONLY_PRIMARY = 5;                    % DCB policy for picking only the primary channel
DSA_POLICY_ONLY_PRIMARY_SPATIAL_REUSE = 6;      % DCB policy for picking only the primary channel, under SR constraints

% Figure settings
CTMC_NODE_SIZE = 500;                           % Node size (circle)
CTMC_NODE_BORDER_WEIGHT = 0.5;                  % Node border weight
CTMC_ARROWHEAD_SIZE = 5;                        % Size of arrowhead
CTMC_NODE_BORDER_COLOR = [0 0 0];               % Black color
CTMC_NODE_FILL_COLOR_FEASIBLE = [1 1 1];        % White color
CTMC_NODE_FILL_COLOR_NOT_FEASIBLE = [.8 .8 .8]; % Gray color
COM_RANGE_TRANSPARENCY = 0.2;                   % Transparency of communication range circle

% Throughput
PACKET_ERR_PROBABILITY = 0.0;                   % Packet error probability
NUM_PACKETS_AGGREGATED = 64;                    % Number of aggregated packets in each transmission
PACKET_LENGTH = 12000;                          % Packet length [bits]
CHANNEL_WIDTH = 20e6;
CHANNEL_WIDTH_MHz = CHANNEL_WIDTH/1e6;
SUSS = 1;                                       % Spatial streams for user
PER = 0;

% Power
CCA_DEFAULT = -82;                              % CCA level [dBm]
CAPTURE_EFFECT = 10;                            % Capture effect [dB]
POWER_TX_DEFAULT = 20;                          % Transmission power [dBm]
GAIN_TX_DEFAULT = 0;                            % Transmitter gain [dB]
GAIN_RX_DEFAULT = 0;                            % Receiver gain [dB]

% Path loss models
PATH_LOSS_FREE_SPACE = 1;                       % Free space path loss model
PATH_LOSS_URBAN_MACRO = 2;                      % Urban macro deployment  (http://ieeexplore.ieee.org/stamp/stamp.jsp?arnumber=6167392)
PATH_LOSS_URBAN_MICRO = 3;                      % Pico/hotzone deployment
PATH_LOSS_INDOOR_SHADOWING = 4;                 % WLAN indorr path loss model
PATH_LOSS_AX_RESIDENTIAL = 5;                   % Retrieved from: https://mentor.ieee.org/802.11/dcn/14/11-14-0882-04-00ax-tgax-channel-model-document.docx
PATH_LOSS_5G_OFFICE = 6;

PATH_LOSS_5G_OFFICE_ALPHA = 0.44;               % [dbm/m] from https://arxiv.org/pdf/1801.00594.pdf

MINIMUM_TX_RATE = 1e6;                          % Minimum tx rate

T_symbol = 9e-6;                                % Time for transmitting an OFDM symbol

% PHY constants
LIGHT_SPEED = 3E8;                              % Speed of light [m/s]

% MCS indexes
MODULATION_FORBIDDEN = -1;
MODULATION_NONE = 0;
MODULATION_BPSK_1_2 = 1;
MODULATION_QPSK_1_2 = 2;
MODULATION_QPSK_3_4 = 3;
MODULATION_16QAM_1_2 = 4;
MODULATION_16QAM_3_4 = 5;
MODULATION_64QAM_2_3 = 6;
MODULATION_64QAM_3_4 = 7;
MODULATION_64QAM_5_6 = 8;
MODULATION_256QAM_3_4 = 9;
MODULATION_256QAM_5_6 = 10;
MODULATION_1024QAM_3_4 = 11;
MODULATION_1024QAM_5_6 = 12;

% Datarate in Mbps for each modulation. Columns: modulation type, rows: number of channels used for tx (1, 2, 4, 8)
mcs_rates = [4, 16, 24, 33, 49, 65, 73, 81, 98, 108, 122, 135; ...
             8, 33, 49, 65, 98, 130, 146, 163, 195, 217, 244, 271; ...
             17, 68, 102, 136, 204, 272, 306, 340, 408, 453, 510, 567; ...
             34, 136, 204, 272, 408, 544, 613, 681, 817, 907, 1021, 1134];
         
% Types of WLANs (Spatial Reuse operation)
WLAN_TYPE_LEGACY = 1;
WLAN_TYPE_INTER_BSS = 2;
WLAN_TYPE_SRG = 3;
WLAN_TYPE_NON_SRG = 4;

% Maximum allowable transmit power
TX_POWER_MAX = 20;
% Minimum and maximum PD thresholds
OBSS_PD_MIN = -82;
OBSS_PD_MAX = -62;

% States that determine the sensitivity used by a given WLAN
STATE_INTRA_BSS_COLOR = 1;
STATE_INTER_BSS_COLOR = 2;
STATE_INTRA_SRG = 3;
STATE_INTER_SRG = 4;

STATE_DEFAULT = 1;
STATE_NONSRG_ACTIVATED = 2;
STATE_SRG_ACTIVATED = 3;

save('constants.mat');  % Save constants into current folder