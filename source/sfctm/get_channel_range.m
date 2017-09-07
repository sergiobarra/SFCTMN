%%% * Spatial-Flexible CTMN for WLANs                                   *
%%% * Author: Sergio Barrachina-Munoz (sergio.barrachina@upf.edu)       *
%%% * Copyright (C) 2017-2022, and GNU GPLd, by Sergio Barrachina-Munoz *
%%% * GitHub repository: https://github.com/sergiobarra/SFCTMN          *
%%% * More info on https://www.upf.edu/en/web/sergiobarrachina          *
%%% *********************************************************************

function [left_ch, right_ch, wlan_active, num_channels, range] = get_channel_range( channel_array )
    %GET_CHANNEL_RANGE returns the left and right basic channel
    %identifier used by a WLAN whose channel usage is represented by a boolean array where colums are channel identifiers.
    % Input:
    %   - channel_array: array of WLANs whose elements represent if a basic channel is used or not.
    % Output:
    %   - left_ch (a.k.a "a"): left channel being used by the WLAN
    %   - right_channel (a.k.a "b"): right channel being used by the WLAN
    %   - wlan_active: boolean for identifying if WLAN is actually transmitting (i.e. active)
    
    channels_for_tx = find(channel_array == true);
    num_channels_used = length(channels_for_tx);
    if num_channels_used > 0
        left_ch = channels_for_tx(1);
        right_ch = channels_for_tx(end);
        num_channels = right_ch - left_ch + 1;
        range = [left_ch right_ch];
        wlan_active = true;
    else
        left_ch = 0;   % No channel range is used for TX
        right_ch = 0;  % No channel range is used for TX
        num_channels = 0;
        wlan_active = false;
        range = [0 0];
    end

end

