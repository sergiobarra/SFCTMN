function [PL] = path_loss_free_space(distance_m,frequency_MHz)
    %PATH_LOSS_FREE_SPACE Summary of this function goes here
    %   Detailed explanation goes here
    PL = 20 * log10(distance_m) + 20 * log10(frequency_MHz) - 27.55;
end

