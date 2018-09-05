%%% *********************************************************************
%%% * Spatial-Flexible CTMN for WLANs                                   *
%%% * Author: Sergio Barrachina-Munoz (sergio.barrachina@upf.edu)       *
%%% * Copyright (C) 2017-2022, and GNU GPLd, by Sergio Barrachina-Munoz *
%%% * GitHub repository: https://github.com/sergiobarra/SFCTMN          *
%%% * More info on https://www.upf.edu/en/web/sergiobarrachina          *
%%% *********************************************************************

function [ power_rx ] = compute_power_received(distance, power_tx, G_tx, G_rx, f, path_loss_model )
    
    %COMPUTE_POWER_RECEIVED computes the power received at the receiver from the transmitter
    % Input:
    %   - distance: distance between transmitter and receiver [m]
    %   - power_tx: transmission power [dBm]
    %   - G_tx: gain at the transmitter [dB]
    %   - G_rx: gain at the receiver [dB]
    %   - f: carrier frequency [Hz]
    %   - path_loss_model: path loss model index
    % Output:
    %   - power_rx: power received [dBm]
    
    load('constants.mat');  % Load constants into workspace
    
    switch path_loss_model
        
        case PATH_LOSS_FREE_SPACE
            
            loss = 20 * log10(distance) + 20 * log10(f) - 147.55;
            
        case PATH_LOSS_URBAN_MACRO
            
            error('Model not implemented yet')
            
        case PATH_LOSS_URBAN_MICRO
            
            error('Model not implemented yet')
            
        case PATH_LOSS_INDOOR_SHADOWING
            
            PL0 = 20;           % Path-loss factor
            shadowing = 9.5;    % Shadowing factor
            obstacles = 30;     % Obstacles factor
            gamma = 5;        % Gamma factor (depends on central frequency)
            % loss = PL0 + 10 * gamma * log10(distance) + shadowing/2 + (distance/10) .* obstacles/2;  
            loss = PL0 + 10 * gamma * log10(distance);
                      
 		% IEEE 802.11ax uses the TGn channel B path loss model for performance evaluation of simulation scenario #1
        % with extra indoor wall and floor penetration loss.
        case PATH_LOSS_AX_RESIDENTIAL
            
            n_walls = 10;                % Wall frequency
            n_floors = 3;                % Floor frequency
            d_BP = 5;                    % Break-point distance (m)

            if distance >= d_BP
               breakpoint_loss = 35*log10(distance/5);
            else 
               breakpoint_loss = 0;
            end

            frequency_ghz = f / 1e9;
            
            loss = 40.05 + 20*log10(frequency_ghz/2.4) + 20 * log10(min(distance,5)) + ...
                   breakpoint_loss + 18.3*(distance/n_floors)^(((distance/n_floors)+2)/...
                   ((distance/n_floors)+1) - 0.46) + 5*(distance/n_walls);            
            
        case PATH_LOSS_WMN_SEMINAR
            
            PL0 = 30;
            gamma = 4.4;
            loss = PL0 + 10*gamma*log10(distance);
            
        case PATH_LOSS_ROOM_CORRIDOR_5250KHZ
                       
            d_BP = 9;
            
            if distance <= d_BP
               loss = 53.2 + 25.8 * log10(distance);
            else 
               loss = 56.4 + 29.1 * log10(distance);
            end
                                               
        otherwise
             error('Unknwown path loss model!')
    end
    power_rx = power_tx + G_rx + G_tx - loss;
    
end

