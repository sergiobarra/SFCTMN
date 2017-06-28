%%% WLAN CTMC Analysis
%%% Author: Sergio Barrachina (sergio.barrachina@upf.edu)
%%% File description: script for generating the system configuration

path_loss_model = PATH_LOSS_FREE_SPACE;
access_protocol_type = ACCESS_PROTOCOL_IEEE80211;
flag_hardcode_distances = true;
carrier_frequency = 2.4E9;             % Carrier frequency [MHz] WiFi 5 GHz

% DSA policy type
dsa_policy_type = DSA_POLICY_AGGRESSIVE;
% dsa_policy_type = DSA_POLICY_ONLY_MAX;
% dsa_policy_type = DSA_POLICY_EXPLORER_UNIFORM;
% dsa_policy_type = DSA_POLICY_EXPLORER_LADDER;

save('system_conf.mat');  % Save system configuration into current folder