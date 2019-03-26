%%% *********************************************************************
%%% * Spatial-Flexible CTMN for WLANs                                   *
%%% * Author: Sergio Barrachina-Munoz (sergio.barrachina@upf.edu)       *
%%% * Copyright (C) 2017-2022, and GNU GPLd, by Sergio Barrachina-Munoz *
%%% * GitHub repository: https://github.com/sergiobarra/SFCTMN          *
%%% * More info on https://www.upf.edu/en/web/sergiobarrachina          *
%%% *********************************************************************

function [ limited_tx_power ] = apply_power_restriction( cca_values, TX_PWR_REF )
    
    %
    % Input:
    %   - 
    % Output:
    %   - 
    
    load('constants.mat');  % Load constants into workspace
    %load('configuration_system.mat');  % Load constants into workspace
    
    limited_tx_power = zeros (1, size(cca_values, 2));
    
    for i = 1 : size(cca_values, 2)
        limited_tx_power(i) = min(TX_POWER_MAX , TX_PWR_REF ...
          - (cca_values(i) - OBSS_PD_MIN));  
    end
    
end