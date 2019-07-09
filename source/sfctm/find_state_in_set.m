%%% *********************************************************************
%%% * Spatial-Flexible CTMN for WLANs                                   *
%%% * Author: Sergio Barrachina-Munoz (sergio.barrachina@upf.edu)       *
%%% * Copyright (C) 2017-2022, and GNU GPLd, by Sergio Barrachina-Munoz *
%%% * GitHub repository: https://github.com/sergiobarra/SFCTMN          *
%%% * More info on https://www.upf.edu/en/web/sergiobarrachina          *
%%% *********************************************************************

function [ is_state_in_set, index ] = find_state_in_set( s, S )
    %IS_STATE_IN_SET determines if a given state is in a given set of states
    % Input:
    %   - s: state in matrix form (wlan x channels)
    %   - S: set of states in cell array form
    % Output:
    %   - state_in_set: flag identifying if state s in set S
    %   - index: index of state s in S (if present)
    
    is_state_in_set = false;
    index = 0;
    
    for s_aux = 1 : length(S)
        if isequal(s, S{s_aux})
            is_state_in_set = true;
            index = s_aux;
            break;
        end
    end
end

