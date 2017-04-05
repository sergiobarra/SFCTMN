%%% WLAN CTMC Analysis
%%% Author: Sergio Barrachina (sergio.barrachina@upf.edu)
%%% File description: constant parameters to be used by different matlab scripts

% Input
INPUT_NUM_FIELDS = 8;                           % Index of code in the input file
INPUT_FIELD_IX_CODE = 1;                        % Index of code in the input file
INPUT_FIELD_PRIMARY_CH = 2;                     % Index of primary channel in the input file
INPUT_FIELD_LEFT_CH = 3;                        % Index of left channel in the input file
INPUT_FIELD_RIGHT_CH = 4;                       % Index of right channel in the input file
INPUT_FIELD_NUM_NODES = 5;                      % Index of number of nodes in the input file
INPUT_FIELD_POS_X = 6;                          % Index of pos X in the input file
INPUT_FIELD_POS_Y = 7;                          % Index of pos Y in the input file
INPUT_FIELD_POS_Z = 8;                          % Index of pos Z in the input file
INPUT_FIELD_TX_POWER = 9;                       % Index of pos Y in the input file
INPUT_FIELD_CCA = 10;                           % Index of pos Z in the input file
INPUT_FIELD_LAMBDA = 11;                        % Index of lambda in the input file

% System configuration
LABELS_DICTIONARY_ACCESS_PROTOCOL = ['Log2maps';'Adjacent';'IE802.11'];
LABELS_DICTIONARY_DSA_POLICY = ['Aggressive';'OnlyMax   ';'ExplorerUn';'ExplorerLa'];

% CTMC
FORWARD_TRANSITION = 1;                         % CTMC forward transition
BACKWARD_TRANSITION = 2;                        % CTMC backward transition
ACCESS_PROTOCOL_LOG2 = 0;                       % Log2 mapping channel access protocol
ACCESS_PROTOCOL_ADJACENT = 1;                   % Continuous mapping channel access protocol
ACCESS_PROTOCOL_IEEE80211 = 2;                  % IEEE 802.11 channel access protocol
LABELS_DICTIONARY = ['A';'B';'C';'D';'E';'F';'G';'H';'I';'K'];  % Encoding of WLAN labels. From code to label (e.g. 2 --> B)
COLORS_DICTIONARY = [.9 .9 0; .9 0 .9; 0 .9 .9; .9 0 0;...
    0 .9 0; 0 0 .9; .5 .5 .5; .2 .5 .2; .9 .5 .1; .1 .5 .9];  % Encoding of WLAN labels. From code to label (e.g. 2 --> B)

MU = [81.5727 150.8068 0 215.7497 0 0 0 284.1716];  % Packet departure rate depending on channels

% DSA-DCB policies
DSA_POLICY_AGGRESSIVE = 1;                      % DSA policy for picking always the maximum channel width available
DSA_POLICY_ONLY_MAX = 2;                        % DSA policy for picking only the whole available range when possible
DSA_POLICY_EXPLORER_UNIFORM = 3;                % DSA policy for picking one of the ranges found free uniformly
DSA_POLICY_EXPLORER_LADDER = 4;                  % DSA policy for picking one of the range found free depending on weights

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

% Power
CCA_DEFAULT = -82;                              % CCA level [dBm]
CAPTURE_EFFECT = 10;                            % Capture effect [dB]
POWER_TX_DEFAULT = 15;                          % Transmission power [dBm]
GAIN_TX_DEFAULT = 0;                            % Transmitter gain [dB]
GAIN_RX_DEFAULT = 0;                            % Receiver gain [dB]
PATH_LOSS_FREE_SPACE = 0;                       % Free space path loss model
PATH_LOSS_URBAN_MACRO = 1;                      % Urban macro deployment  (http://ieeexplore.ieee.org/stamp/stamp.jsp?arnumber=6167392)
PATH_LOSS_URBAN_MICRO = 2;                      % Pico/hotzone deployment
LIGHT_SPEED = 3E8;                              % Speed of light [m/s]
FREQUENCY = 2.4E9;                              % Carrier frequency [MHz] WiFi 2.4 GHz
NOISE_DBM = -100;                               % Ambient noise [dBm]

save('constants.mat');  % Save constants into current folder