%%% *********************************************************************
%%% * Spatial-Flexible CTMN for WLANs                                   *
%%% * Author: Sergio Barrachina-Munoz (sergio.barrachina@upf.edu)       *
%%% * Copyright (C) 2017-2022, and GNU GPLd, by Sergio Barrachina-Munoz *
%%% * GitHub repository: https://github.com/sergiobarra/SFCTMN          *
%%% * More info on https://www.upf.edu/en/web/sergiobarrachina          *
%%% *********************************************************************

function [ PSI_cell, num_global_states, PSI ] = identify_global_states( ...
    wlans, num_channels_system, num_wlans, access_protocol )
    %IDENTIFY_POSSIBLE_STATES returns the set of global states according to a given channel access protocol
    % Input:
    %   - wlans: array of structures with wlans info
    %   - num_channels_system: number of channels in the system
    %   - num_wlans: number of WLANs in the system
    %   - access_protocol: type of channel access protocol (0: log2 mapping)
    % Output:
    %   - PSI_cell: cell array containing the global states
    %   - num_global_states: number of global states
    %   - PSI: 3d matrix representing the global states
    
    load('constants_sfctmn_framework.mat');  % Load constants into workspace
    
    for wlan_ix = 1 : num_wlans
             
        max_width = (wlans(wlan_ix).range(2) - wlans(wlan_ix).range(1) + 1);    % Max. channel width WLAN wlan may use       
        wlans(wlan_ix).states(1,:) = false(1, num_channels_system);             % Instantiate first state as unactive
        acceptable_widths = []; % Set of acceptable widths (determined by the channel access protocol)
        
        switch access_protocol     % Identify acceptable channel widths according to channel access protocol
            
            % Any channel range of size 2^k, where k = 0 : log2(num_channels_system)
            case ACCESS_PROTOCOL_LOG2
               
                % Alessandro code
                acceptable_widths = 2.^(0:log2(max_width));
 
                for width_ix = 1 : numel(acceptable_widths)     % for every acceptable channel width
                    width_aux = acceptable_widths(width_ix);        % pick a width
                    for left_ch_ix = (wlans(wlan_ix).primary - width_aux + 1) : wlans(wlan_ix).primary
                        if ((left_ch_ix >= 1) && (left_ch_ix <= num_channels_system)...
                            && (left_ch_ix + width_aux - 1 <= num_channels_system)...
                            && (left_ch_ix >= wlans(wlan_ix).range(1))...
                            && (left_ch_ix + width_aux - 1 <= wlans(wlan_ix).range(2)))
                        
                            wlans(wlan_ix).states(end + 1, left_ch_ix:(left_ch_ix + width_aux - 1)) = true;
                            wlans(wlan_ix).widths(end + 1) = width_aux;
                        end
                    end
                end
              
            % IEEE 802.11 channel access protocol. Channel ranges of size 2^k with some specific constraints.
            case ACCESS_PROTOCOL_IEEE80211
                
                acceptable_widths = 2.^(0:log2(max_width));     % Channels of size 2^k
                                
                for width_ix = 1 : numel(acceptable_widths)     % For every acceptable channel width

                    width_aux = acceptable_widths(width_ix);

                    for left_ch_ix = (wlans(wlan_ix).primary - width_aux + 1) : wlans(wlan_ix).primary

                        if ((left_ch_ix >= 1) && (left_ch_ix <= num_channels_system)...
                                && (left_ch_ix + width_aux - 1 <= num_channels_system)...
                                && (left_ch_ix >= wlans(wlan_ix).range(1))...
                                && (left_ch_ix + width_aux - 1 <= wlans(wlan_ix).range(2)))

                            candidate_range = left_ch_ix:(left_ch_ix + width_aux - 1);
                            num_channels_candidate = (left_ch_ix + width_aux - 1) - left_ch_ix + 1;
                            is_acceptable_candidate_range = true;
                            
                            % Determine if candidate range complies with IEEE 802.11 channelization constraints
                            switch num_channels_candidate
                                case 1
                                    % candidate range remains the same
                                case 2
                                    if isequal(candidate_range, 2:3) || isequal(candidate_range, 4:5) ||...
                                            isequal(candidate_range, 6:7)
                                        is_acceptable_candidate_range = false;
                                    end
                                case 4                                    
                                    if ~(isequal(candidate_range, 1:4) || isequal(candidate_range, 5:8))
                                        is_acceptable_candidate_range = false;
                                    end                                    
                                case 8
                                    % candidate range remains the same
                                otherwise
                                    % unkown number of channels
                                    error('Unkown number of channels')
                            end

                            if is_acceptable_candidate_range                               
                                wlans(wlan_ix).states(end + 1, left_ch_ix : (left_ch_ix + width_aux - 1)) = true;
                                wlans(wlan_ix).widths(end + 1) = width_aux;     
                            end
                            
                        end
                    end
                end   
                
            % Any range of adjacent channels
            case ACCESS_PROTOCOL_ADJACENT
                acceptable_widths = 1 : max_width;
                
                for width_ix = 1 : numel(acceptable_widths)     % for every acceptable channel width
                    
                    width_aux = acceptable_widths(width_ix);        % pick a width
                    
                    for left_ch_ix = (wlans(wlan_ix).primary - width_aux + 1) : wlans(wlan_ix).primary
                        if ((left_ch_ix >= 1) && (left_ch_ix <= num_channels_system)...
                                && (left_ch_ix + width_aux - 1 <= num_channels_system)...
                                && (left_ch_ix >= wlans(wlan_ix).range(1))...
                                && (left_ch_ix + width_aux - 1 <= wlans(wlan_ix).range(2)))
                            wlans(wlan_ix).states(end + 1, left_ch_ix:(left_ch_ix + width_aux - 1)) = true;
                            wlans(wlan_ix).widths(end + 1) = width_aux;
                        end
                    end
                end
            
            % Any range of adjacent channels    
            case ACCESS_PROTOCOL_SR_SINGLE_CHANNEL

                wlans(wlan_ix).states(end + 1, wlans(wlan_ix).primary) = true;
                wlans(wlan_ix).widths(end + 1) = 1;     

                %%%%%%%%%%%%% SR OPERATION
                if wlans(wlan_ix).non_srg_activated                                       
                    wlans(wlan_ix).states(end + 1, wlans(wlan_ix).primary) = STATE_NONSRG_ACTIVATED;   
                    wlans(wlan_ix).widths(end + 1) = 1;
                end
                
                if wlans(wlan_ix).non_srg_activated && wlans(wlan_ix).srg > 0 
                    % In case SRG is used, generate states for SRG OBSS PD
                    wlans(wlan_ix).states(end + 1, wlans(wlan_ix).primary) = STATE_SRG_ACTIVATED;   
                    wlans(wlan_ix).widths(end + 1) = 1;
                end   
                %%%%%%%%%%%%% SR OPERATION
                            
            otherwise
                error('Protocol type unknown!');
        end
    end
            
    % Use Alessandro's function for generating global states starting from WLAN own global states
    PSI_alessandro = create_global_states(wlans);   
    num_global_states = size(PSI_alessandro.states,1);
    PSI = zeros(size(PSI_alessandro.states,1), num_wlans, num_channels_system);
    
    PSI_cell =  {}; % PSI in cell format (easier to handle in Matlab code)
    for psi_ix = 1 : num_global_states
        for wlan_ix = 1 : num_wlans            
            PSI(psi_ix,wlan_ix,:) = wlans(wlan_ix).states(PSI_alessandro.states(psi_ix,wlan_ix),:);
            PSI_cell{psi_ix} = squeeze(PSI(psi_ix,:,:));
        end
    end
    
    % Workaround for the case of just one channel in the system. Convert row to column vector
    if num_channels_system == 1
        for psi_ix = 1 : num_global_states
            PSI_cell{psi_ix} = PSI_cell{psi_ix}';
        end
    end
    
end