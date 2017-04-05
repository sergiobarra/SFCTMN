%%% Author: Sergio Barrachina (sergio.barrachina@upf.edu)
%%% File description: function for computing the power received at a given node

function [ power_rx ] = compute_power_received(distance, power_tx, G_tx, G_rx, f, path_loss_model )
    
    %COMPUTE_POWER_RECEIVED computes the power received at the receiver from the transmitter
    %   Detailed explanation goes here
    
    load('constants.mat');  % Load constants into workspace   

    switch path_loss_model
        
        case PATH_LOSS_FREE_SPACE
            loss = 20 * log10(distance) + 20 * log10(f) + 20 * log10(4*pi/LIGHT_SPEED); 
            power_rx = power_tx + G_rx + G_tx - loss;
            
        case PATH_LOSS_URBAN_MACRO
            error('Model not implemented yet')
            
        case PATH_LOSS_URBAN_MICRO
            error('Model not implemented yet')
            
        otherwise
             error('Unknwown path loss model!')
    end
    
end

