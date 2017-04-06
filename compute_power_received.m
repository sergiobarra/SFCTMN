%%% Author: Sergio Barrachina (sergio.barrachina@upf.edu)
%%% File description: function for computing the power received at a given node

function [ power_rx ] = compute_power_received(distance, power_tx, G_tx, G_rx, f, path_loss_model )
    
    %COMPUTE_POWER_RECEIVED computes the power received at the receiver from the transmitter
    %   power_rx: power received [dBm]
    
    load('constants.mat');  % Load constants into workspace

    switch path_loss_model
        
        case PATH_LOSS_FREE_SPACE
            
            loss = 20 * log10(distance) + 20 * log10(f) + 20 * log10(4*pi/LIGHT_SPEED); 
            
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
            
            
        % Retrieved from: https://mentor.ieee.org/802.11/dcn/14/11-14-0882-04-00ax-tgax-channel-model-document.docx
        % IEEE 802.11ax uses the TGn channel B path loss model for performance evaluation of simulation scenario #1
        % with extra indoor wall and floor penetration loss.
        case PATH_LOSS_AX_RESIDENTIAL
            
             n_walls = 10;  % Wall frequency
             n_floors = 3;  % Floor frequency
             L_iw = 5;      % Penetration for a single wall (dB)
             f_mhz = f * 1E-6;
             d_km = distance * 1E-3;
             LFS = 32.4 + 20 * log10(f_mhz) + 20 * log10(d_km);
             d_BP = 5;      % Break-point distance (m)

            if distance >= d_BP
                loss = LFS + 35*log10(distance/d_BP) + 18.3 * n_floors^(((n_floors+2)/(n_floors+1)) - 0.46) + L_iw * n_walls;
                
            else 
                loss = LFS;
            end
            
            loss
                                    
        otherwise
             error('Unknwown path loss model!')
    end
    
    power_rx = power_tx + G_rx + G_tx - loss;
    
end

