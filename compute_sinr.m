%%% WLAN CTMC Analysis
%%% Author: Sergio Barrachina (sergio.barrachina@upf.edu)
%%% File description: function for computing the Signal to Interference
%%% plus Noise

function sinr = compute_sinr(interest_power, interference_power, noise_power)
    %COMPUTE_SINR Summary of this function goes here
    % Input:
    %   - interest_power: power of interest [dBm]
    %   - interference_power: sum of interference powers [dBm]
    %   - noise_power: ambient noise power [dBm]
    % Output:
    %   - sinr: SINR [dB]
    
    interest_power_mw = 10^(interest_power/10);
          
    interference_power_mw = 10^(interference_power/10);

    noise_power_mw = 10^(noise_power/10);

    sinr_linear = interest_power_mw / (interference_power_mw + noise_power_mw);

    sinr = 10 * log10(sinr_linear);
    
    
end

