%%% WLAN CTMC Analysis
%%% Author: Sergio Barrachina (sergio.barrachina@upf.edu)
%%% File description: function for finding the probability of WLANs to tranmsit in any number of channels

function [ prob_tx_in_num_channels ] = get_probability_tx_in_n_channels_old( S_cell, num_wlans, num_channels_system,...
        p_equilibrium )
    %GET_PROBABILITY_TX_IN_N_CHANNELS returns the probability of transmitting in a given number of channels
    % Input:
    %   - S_cell: cell array representing the feasible states
    %   - num_wlans: number of WLANs in the system
    %   - num_channels_system:  number of channels in the system
    %   - p_equilibrium: equilibrium distribution array (pi)
    % Output:
    %   - prob_tx_in_num_channels: array whose element w,n is the probability of WLAN w of transmiting in n channels
   
    S_num_states = length(S_cell);  % Number of feasible states

    prob_tx_in_num_channels = zeros(num_wlans, num_channels_system + 1);    

    for s_ix = 1 : S_num_states

        pi_s = p_equilibrium(s_ix); % probability of being in state s

        for wlan_ix = 1 : num_wlans

            % Number of channels used by WLAN wlan in state s
            [~, ~ ,~ ,num_channels] = get_channel_range(S_cell{s_ix}(wlan_ix,:));
            
            prob_tx_in_num_channels(wlan_ix, num_channels + 1) = prob_tx_in_num_channels(wlan_ix, num_channels + 1)...
                + pi_s;

        end
    end
end

