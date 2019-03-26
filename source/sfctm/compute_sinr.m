%%% *********************************************************************
%%% * Spatial-Flexible CTMN for WLANs                                   *
%%% * Author: Sergio Barrachina-Munoz (sergio.barrachina@upf.edu)       *
%%% * Copyright (C) 2017-2022, and GNU GPLd, by Sergio Barrachina-Munoz *
%%% * GitHub repository: https://github.com/sergiobarra/SFCTMN          *
%%% * More info on https://www.upf.edu/en/web/sergiobarrachina          *
%%% *********************************************************************

function sinr = compute_sinr(interest_power, interference_power, noise_power)
    %COMPUTE_SINR Summary of this function goes here
    % Input:
    %   - interest_power: power of interest [dBm]
    %   - interference_power: sum of interference powers [dBm]
    %   - noise_power: ambient noise power [dBm]
    % Output:
    %   - sinr: SINR [dB]
        
    interest_power_mw = db2pow(interest_power);
          
    interference_power_mw = db2pow(interference_power);

    noise_power_mw = db2pow(noise_power);

    sinr_linear = interest_power_mw / (interference_power_mw + noise_power_mw);

    sinr = pow2db(sinr_linear);
    
    
end

