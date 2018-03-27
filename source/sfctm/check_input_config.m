%%% * Spatial-Flexible CTMN for WLANs                                   *
%%% * Author: Sergio Barrachina-Munoz (sergio.barrachina@upf.edu)       *
%%% * Copyright (C) 2017-2022, and GNU GPLd, by Sergio Barrachina-Munoz *
%%% * GitHub repository: https://github.com/sergiobarra/SFCTMN          *
%%% * More info on https://www.upf.edu/en/web/sergiobarrachina          *
%%% *********************************************************************

function [ is_config_ok ] = check_input_config( wlans )
    %CHECK_INPUT_CONFIG checks if the provided configuration input complies with some basic rules
    % Input:
    %   - wlans: array of structures with wlans info
    % Output:
    %   - is_config_ok: (deprecated) boolean for identifying if configuration is properly entered.
    
    load('constants.mat');  % Load constants into workspace
        
    is_config_ok = true;
    
    num_wlans = length(wlans);  % Number of WLANs in the system
    
    for wlan_ix = 1 : num_wlans
    
        % Primary channel must be inside the channel range
        channels_in_range = wlans(wlan_ix).range(1) : wlans(wlan_ix).range(2);
        
        % Look for the primary channel in the range
        primary_ix = find(channels_in_range == wlans(wlan_ix).primary, 1);
        
        if isempty(primary_ix)  % Primary channel is not inside the range
  
            error([' - Primary channel (' num2str(wlans(wlan_ix).primary) ') of WLAN '...
                LABELS_DICTIONARY(wlans(wlan_ix).code) ' outside its range (' num2str(channels_in_range(1))...
                ' - ' num2str(channels_in_range(end)) ')']);
  
            % is_config_ok = false;
            
        end
    
    end
    
end

