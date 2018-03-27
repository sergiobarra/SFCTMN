function mcs_per_wlan = compute_MCS(power_from_ap, num_channels)
% MCS_PER_WLAN computes the allowed Modulation Coding Scheme for each WLAN
% transmitting in different number of channels
% INPUT:
%   * power_from_ap: power that each STA receives from its AP in dBm
%   * num_channels: number of channels allowed in the system
% OUTPUT:
%   * mcs_per_wlan: MCS in each WLAN for each number of channels used for tx 
%     (rows: number of channels, columns: MCS index)

    load('constants.mat');  % Load constants into workspace

    num_wlans = size(power_from_ap, 2);
    mcs_per_wlan = zeros(num_wlans, num_channels);    
    
    for wlan_ix = 1 : num_wlans
        
        for ch_ix = 1 : (log2(num_channels) + 1) 	% For 1, 2, 4 and 8 channels

            if power_from_ap(wlan_ix, wlan_ix) < -82 +((ch_ix-1)*3) 
                mcs_per_wlan(wlan_ix, ch_ix) = MODULATION_FORBIDDEN;
            elseif (power_from_ap(wlan_ix, wlan_ix) >= -82 + ((ch_ix-1)*3) && power_from_ap(wlan_ix, wlan_ix) < -79 +((ch_ix-1)*3))
                mcs_per_wlan(wlan_ix, ch_ix) = MODULATION_BPSK_1_2;
            elseif (power_from_ap(wlan_ix, wlan_ix) >= -79 + ((ch_ix-1)*3) && power_from_ap(wlan_ix, wlan_ix) < -77 +((ch_ix-1)*3))
                mcs_per_wlan(wlan_ix, ch_ix) = MODULATION_QPSK_1_2;
            elseif (power_from_ap(wlan_ix, wlan_ix) >= -77 + ((ch_ix-1)*3) && power_from_ap(wlan_ix, wlan_ix) < -74 +((ch_ix-1)*3))
                mcs_per_wlan(wlan_ix, ch_ix) = MODULATION_QPSK_3_4;
            elseif (power_from_ap(wlan_ix, wlan_ix) >= -74 + ((ch_ix-1)*3) && power_from_ap(wlan_ix, wlan_ix) < -70 +((ch_ix-1)*3))
                mcs_per_wlan(wlan_ix, ch_ix) = MODULATION_16QAM_1_2;
            elseif (power_from_ap(wlan_ix, wlan_ix) >= -70 + ((ch_ix-1)*3) && power_from_ap(wlan_ix, wlan_ix) < -66 +((ch_ix-1)*3))
                mcs_per_wlan(wlan_ix, ch_ix) = MODULATION_16QAM_3_4;
            elseif (power_from_ap(wlan_ix, wlan_ix) >= -66 + ((ch_ix-1)*3) && power_from_ap(wlan_ix, wlan_ix) < -65 +((ch_ix-1)*3))
                mcs_per_wlan(wlan_ix, ch_ix) = MODULATION_64QAM_2_3;
            elseif (power_from_ap(wlan_ix, wlan_ix) >= -65 + ((ch_ix-1)*3) && power_from_ap(wlan_ix, wlan_ix) < -64 +((ch_ix-1)*3))
                mcs_per_wlan(wlan_ix, ch_ix) = MODULATION_64QAM_3_4;
            elseif (power_from_ap(wlan_ix, wlan_ix) >= -64 + ((ch_ix-1)*3) && power_from_ap(wlan_ix, wlan_ix) < -59 +((ch_ix-1)*3))
                mcs_per_wlan(wlan_ix, ch_ix) = MODULATION_64QAM_5_6;
            elseif (power_from_ap(wlan_ix, wlan_ix) >= -59 + ((ch_ix-1)*3) && power_from_ap(wlan_ix, wlan_ix) < -57 +((ch_ix-1)*3))
                mcs_per_wlan(wlan_ix, ch_ix) = MODULATION_256QAM_3_4;
            elseif (power_from_ap(wlan_ix, wlan_ix) >= -57 + ((ch_ix-1)*3) && power_from_ap(wlan_ix, wlan_ix) < -54 +((ch_ix-1)*3))
                mcs_per_wlan(wlan_ix, ch_ix) = MODULATION_256QAM_5_6;
            else
%             elseif (power_from_ap(wlan_ix, wlan_ix) >= -54 + (ch_ix*3) && power_from_ap(wlan_ix, wlan_ix) < -52 +(ch_ix*3))
                mcs_per_wlan(wlan_ix, ch_ix) = MODULATION_1024QAM_3_4;
%             else
%                 mcs_per_wlan(wlan_ix, ch_ix) = MODULATION_1024QAM_5_6;
            end

        end
    
    end
           
end