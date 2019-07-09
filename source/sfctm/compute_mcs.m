function mcs_per_wlan = compute_mcs(PSI_cell, power_from_ap_cell, num_channels_system)
% MCS_PER_WLAN computes the allowed Modulation Coding Scheme for each WLAN
% transmitting in different number of channels
% INPUT:
%   * power_from_ap: power that each STA receives from its AP in dBm
%   * num_channels: number of channels allowed in the system
% OUTPUT:
%   * mcs_per_wlan: MCS in each WLAN for each number of channels used for tx 
%     (rows: number of channels, columns: MCS index)

    load('constants_sfctmn_framework.mat');  % Load constants into workspace

    mcs_per_wlan = cell(1, size(power_from_ap_cell, 2));
    
    for state_ix = 1 : size(power_from_ap_cell, 2)        
        power_state_ix = power_from_ap_cell{state_ix};
        num_wlans = size(power_from_ap_cell{state_ix}, 1);
        mcs_per_wlan{state_ix} = zeros(num_wlans, num_channels_system);                          
        for wlan_ix = 1 : num_wlans
            for ch_ix = 1 : num_channels_system %(log2(num_channels_system) + 1) 	% For 1, 2, 4 and 8 channels
                if PSI_cell{state_ix}(wlan_ix) > 0 
                    if power_state_ix(wlan_ix,ch_ix) < -82 +((ch_ix-1)*3) 
                        %mcs_per_wlan{state_ix}(wlan_ix, ch_ix) = MODULATION_FORBIDDEN;
                        mcs_per_wlan{state_ix}(wlan_ix, ch_ix) = MODULATION_BPSK_1_2; % Default MCS (to always start the TX)
                    elseif (power_state_ix(wlan_ix,ch_ix) >= -82 + ((ch_ix-1)*3) && power_state_ix(wlan_ix,ch_ix) < -79 +((ch_ix-1)*3))
                        mcs_per_wlan{state_ix}(wlan_ix, ch_ix) = MODULATION_BPSK_1_2;
                    elseif (power_state_ix(wlan_ix,ch_ix) >= -79 + ((ch_ix-1)*3) && power_state_ix(wlan_ix,ch_ix) < -77 +((ch_ix-1)*3))
                        mcs_per_wlan{state_ix}(wlan_ix, ch_ix) = MODULATION_QPSK_1_2;
                    elseif (power_state_ix(wlan_ix,ch_ix) >= -77 + ((ch_ix-1)*3) && power_state_ix(wlan_ix,ch_ix) < -74 +((ch_ix-1)*3))
                        mcs_per_wlan{state_ix}(wlan_ix, ch_ix) = MODULATION_QPSK_3_4;
                    elseif (power_state_ix(wlan_ix,ch_ix) >= -74 + ((ch_ix-1)*3) && power_state_ix(wlan_ix,ch_ix) < -70 +((ch_ix-1)*3))
                        mcs_per_wlan{state_ix}(wlan_ix, ch_ix) = MODULATION_16QAM_1_2;
                    elseif (power_state_ix(wlan_ix,ch_ix) >= -70 + ((ch_ix-1)*3) && power_state_ix(wlan_ix,ch_ix) < -66 +((ch_ix-1)*3))
                        mcs_per_wlan{state_ix}(wlan_ix, ch_ix) = MODULATION_16QAM_3_4;
                    elseif (power_state_ix(wlan_ix,ch_ix) >= -66 + ((ch_ix-1)*3) && power_state_ix(wlan_ix,ch_ix) < -65 +((ch_ix-1)*3))
                        mcs_per_wlan{state_ix}(wlan_ix, ch_ix) = MODULATION_64QAM_2_3;
                    elseif (power_state_ix(wlan_ix,ch_ix) >= -65 + ((ch_ix-1)*3) && power_state_ix(wlan_ix,ch_ix) < -64 +((ch_ix-1)*3))
                        mcs_per_wlan{state_ix}(wlan_ix, ch_ix) = MODULATION_64QAM_3_4;
                    elseif (power_state_ix(wlan_ix,ch_ix) >= -64 + ((ch_ix-1)*3) && power_state_ix(wlan_ix,ch_ix) < -59 +((ch_ix-1)*3))
                        mcs_per_wlan{state_ix}(wlan_ix, ch_ix) = MODULATION_64QAM_5_6;
                    elseif (power_state_ix(wlan_ix,ch_ix) >= -59 + ((ch_ix-1)*3) && power_state_ix(wlan_ix,ch_ix) < -57 +((ch_ix-1)*3))
                        mcs_per_wlan{state_ix}(wlan_ix, ch_ix) = MODULATION_256QAM_3_4;
                    elseif (power_state_ix(wlan_ix,ch_ix) >= -57 + ((ch_ix-1)*3) && power_state_ix(wlan_ix,ch_ix) < -54 +((ch_ix-1)*3))
                        mcs_per_wlan{state_ix}(wlan_ix, ch_ix) = MODULATION_256QAM_5_6;
                    elseif (power_state_ix(wlan_ix,ch_ix) >= -54 + ((ch_ix-1)*3) && power_state_ix(wlan_ix,ch_ix) < -52 +((ch_ix-1)*3))
                        mcs_per_wlan{state_ix}(wlan_ix, ch_ix) = MODULATION_1024QAM_3_4;
                    else
                        mcs_per_wlan{state_ix}(wlan_ix, ch_ix) = MODULATION_1024QAM_5_6;
                    end
                else % If the WLAN is not transmitting in state "state_ix"
                    mcs_per_wlan{state_ix}(wlan_ix, ch_ix) = MODULATION_FORBIDDEN;
                end
            end                
        end        
    end
           
end