%%% *********************************************************************
%%% * Spatial-Flexible CTMN for WLANs                                   *
%%% * Author: Sergio Barrachina-Munoz (sergio.barrachina@upf.edu)       *
%%% * Copyright (C) 2017-2022, and GNU GPLd, by Sergio Barrachina-Munoz *
%%% * GitHub repository: https://github.com/sergiobarra/SFCTMN          *
%%% * More info on https://www.upf.edu/en/web/sergiobarrachina          *
%%% *********************************************************************

%%% File description: script for generating the constant variables

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
INPUT_FIELD_CW = 7;                             % Index of contention window in the input file
INPUT_FIELD_POS_AP_X = 8;                       % Index of pos X in the input file
INPUT_FIELD_POS_AP_Y = 9;                       % Index of pos Y in the input file
INPUT_FIELD_POS_AP_Z = 10;                      % Index of pos Z in the input file
INPUT_FIELD_POS_STA_X = 11;                     % Index of pos X in the input file
INPUT_FIELD_POS_STA_Y = 12;                     % Index of pos Y in the input file
INPUT_FIELD_POS_STA_Z = 13;                     % Index of pos Z in the input file

% Labels
LABELS_DICTIONARY_PATH_LOSS = ...
    ['Free Space ';'Urban Macro';'Urban Pico ';'In-door sh.';'8011ax Res.';'8011ax Res.';'Corridor525'];
LABELS_DICTIONARY_ACCESS_PROTOCOL = ['Log2maps';'Adjacent';'IE802.11'];
LABELS_DICTIONARY_DSA_POLICY = ['Aggressive';'OnlyMax   ';'ExplorerUn';'ExplorerLa'; 'OnlyPrim  '];

% CTMC
FORWARD_TRANSITION = 1;                         % CTMC forward transition
BACKWARD_TRANSITION = 2;                        % CTMC backward transition
ACCESS_PROTOCOL_LOG2 = 0;                       % Log2 mapping channel access protocol
ACCESS_PROTOCOL_ADJACENT = 1;                   % Continuous mapping channel access protocol
ACCESS_PROTOCOL_IEEE80211 = 2;                  % IEEE 802.11 channel access protocol
LABELS_DICTIONARY = ['A';'B';'C';'D';'E';'F';'G';'H';'I';'K'];  % Encoding of WLAN labels. From code to label (e.g. 2 --> B)
COLORS_DICTIONARY = [.9 .9 0; .9 0 .9; 0 .9 .9; .9 0 0;...
    0 .9 0; 0 0 .9; .5 .5 .5; .2 .5 .2; .9 .5 .1; .1 .5 .9];  % Encoding of colors

% DCB policies
DSA_POLICY_AGGRESSIVE = 1;                      % DCB policy for picking always the maximum channel width available
DSA_POLICY_ONLY_MAX = 2;                        % DCB policy for picking only the whole available range when possible
DSA_POLICY_EXPLORER_UNIFORM = 3;                % DCB policy for picking one of the ranges found free uniformly
DSA_POLICY_EXPLORER_LADDER = 4;                 % DCB policy for picking one of the range found free depending on weights
DSA_POLICY_ONLY_PRIMARY = 5;                    % DCB policy for picking just the primary channel when found free

% Figure settings
CTMC_NODE_SIZE = 500;                           % Node size (circle)
CTMC_NODE_BORDER_WEIGHT = 0.5;                  % Node border weight
CTMC_ARROWHEAD_SIZE = 5;                        % Size of arrowhead
CTMC_NODE_BORDER_COLOR = [0 0 0];               % Black color
CTMC_NODE_FILL_COLOR_FEASIBLE = [1 1 1];        % White color
CTMC_NODE_FILL_COLOR_NOT_FEASIBLE = [.8 .8 .8]; % Gray color
COM_RANGE_TRANSPARENCY = 0.2;                   % Transparency of communication range circle

% Path loss models
PATH_LOSS_FREE_SPACE = 1;                       % Free space path loss model
PATH_LOSS_URBAN_MACRO = 2;                      % Urban macro deployment  (http://ieeexplore.ieee.org/stamp/stamp.jsp?arnumber=6167392)
PATH_LOSS_URBAN_MICRO = 3;                      % Pico/hotzone deployment
PATH_LOSS_INDOOR_SHADOWING = 4;                 % WLAN indorr path loss model
PATH_LOSS_AX_RESIDENTIAL = 5;                   % % Retrieved from: https://mentor.ieee.org/802.11/dcn/14/11-14-0882-04-00ax-tgax-channel-model-document.docx
PATH_LOSS_WMN_SEMINAR = 6;
PATH_LOSS_ROOM_CORRIDOR_5250KHZ = 7;             % Xu et al. Indoor Office Propagation Measurements and Path Loss Models at 5.25 GHz�, IEEE VTC 2007.
                                                % dual-slope log-distance model in room-corridor condition

% IEEE 11ax MCS indexes
MODULATION_FORBIDDEN = -1;
MODULATION_BPSK_1_2 = 0;
MODULATION_QPSK_1_2 = 1;
MODULATION_QPSK_3_4 = 2;
MODULATION_16QAM_1_2 = 3;
MODULATION_16QAM_3_4 = 4;
MODULATION_64QAM_2_3 = 5;
MODULATION_64QAM_3_4 = 6;
MODULATION_64QAM_5_6 = 7;
MODULATION_256QAM_3_4 = 8;
MODULATION_256QAM_5_6 = 9;
MODULATION_1024QAM_3_4 = 10;
MODULATION_1024QAM_5_6 = 11;

% PHY constants
LIGHT_SPEED = 3E8;                              % Speed of light [m/s]

% SLOTS
TIME_SLOT = 9E-6;

save('constants.mat');  % Save constants into current folder