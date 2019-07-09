%%% *********************************************************************
%%% * Spatial-Flexible CTMN for WLANs                                   *
%%% * Author: Sergio Barrachina-Munoz (sergio.barrachina@upf.edu)       *
%%% * Copyright (C) 2017-2022, and GNU GPLd, by Sergio Barrachina-Munoz *
%%% * GitHub repository: https://github.com/sergiobarra/SFCTMN          *
%%% * More info on https://www.upf.edu/en/web/sergiobarrachina          *
%%% *********************************************************************

function [ range ] = compute_node_com_range(path_loss_model, power_tx, sensitivity, Grx, Gtx, f)
    % COMPUTE_NODE_COM_RANGE returns de max distance given a maximum power transmission
    %   Arguments:
    %   - path_loss_model: propagation model (0: free-space, 1:...)
    %   - power_tx: transmission power [dBm]
    %   - Grx: receiver gain [dBi]
    %   - Gtx: transmitter gaint [dBi]
    %   - S: sensitivity [dBm]
    %   - f: frequency [Hz]
    %   Returned parameters:
    %   - d_max: Max distance reachable [m]

    load('constants_sfctmn_framework.mat');  % Load constants into workspace

    switch path_loss_model
        case PATH_LOSS_FREE_SPACE
            range = (10^((power_tx-sensitivity + Gtx + Grx)/20) * LIGHT_SPEED)/(4*pi*f);
        case PATH_LOSS_URBAN_MACRO
            range = 10^((power_tx - sensitivity - 8 - 21 * log10(f/900E6) + Gtx + Grx)/37.6);
        case PATH_LOSS_URBAN_MICRO
            range = 10^((power_tx - sensitivity - 23.3 -21 * log10(f/900E6) + Gtx + Grx)/37.6);
        
        case PATH_LOSS_INDOOR_SHADOWING
            
            % Hardcoded for power_tx = 15 dBm, CCA = -82 dBm in 5GHz
            range = 20;
            
        case PATH_LOSS_AX_RESIDENTIAL
            
            % Hardcoded for power_tx = 15 dBm, CCA = -82 dBm in 5GHz
            range = 40;
            
        otherwise
             error('Unknwown path loss model!')
    end
end
