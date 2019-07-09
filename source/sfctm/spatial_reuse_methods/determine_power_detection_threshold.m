%%% ***********************************************************************
%%% *                                                                     *
%%% *             Spatial Reuse Operation in IEEE 802.11ax:               *
%%% *          Analysis, Challenges and Research Opportunities            *
%%% *                                                                     *
%%% * Submission to IEEE Surveys & Tutorials                              *
%%% *                                                                     *
%%% * Authors:                                                            *
%%% *   - Francesc Wilhelmi (francisco.wilhelmi@upf.edu)                  *
%%% *   - Sergio Barrachina-Muñoz  (sergio.barrachina@upf.edu)            *
%%% *   - Boris Bellalta (boris.bellalta@upf.edu)                         *
%%% *   - Cristina Cano (ccanobs@uoc.edu)                                 *
%%% * 	- Ioannis Selinis (ioannis.selinis@surrey.ac.uk)                  *
%%% *                                                                     *
%%% * Copyright (C) 2019-2024, and GNU GPLd, by Francesc Wilhelmi         *
%%% *                                                                     *
%%% * Repository:                                                         *
%%% *  https://github.com/fwilhelmi/tutorial_11ax_spatial_reuse           *
%%% ***********************************************************************

function [ power_detection_threshold ] = determine_power_detection_threshold...
    ( PSI_cell, wlans, state_ix, type_neighboring_wlans, wlan_ix )
    %CHECK_WLAN_TYPE checks if the type of wlan transmitting in a given state
    % Input:
    %   - wlans: array of structures with wlans info
    %   - wlan_ix: index of the potentially inteferred WLAN
    %   - neighboring_wlan_ix: index of the potentially interfering WLAN
    % Output:
    %   - wlan_type: integer indicating the type of WLAN
    
    load('constants_sfctmn_framework.mat');  % Load constants into workspace
        
    LEGACY = false;
    INTER_BSS = false;
    NON_SRG = false;
    SRG = false;
    for i = 1 : size(wlans, 2)
       if i ~= wlan_ix && PSI_cell{state_ix}(i) == 1
           if type_neighboring_wlans(i) == WLAN_TYPE_LEGACY
                LEGACY = true;
           elseif type_neighboring_wlans(i) == WLAN_TYPE_INTER_BSS
                INTER_BSS = true;
           elseif type_neighboring_wlans(i) == WLAN_TYPE_NON_SRG
                NON_SRG = true;
           elseif type_neighboring_wlans(i) == WLAN_TYPE_SRG
                SRG = true;
           end
       end
    end

    if ~LEGACY && INTER_BSS
       power_detection_threshold = wlans(wlan_ix).obss_pd; 
       %disp(['    - INTER-BSS TRANSMISSION DETECTED in STATE ' num2str(state_ix)])
    elseif ~LEGACY && ~INTER_BSS && NON_SRG
       power_detection_threshold = wlans(wlan_ix).non_srg_obss_pd; 
       %disp(['    - NON-SRG TRANSMISSION DETECTED in STATE ' num2str(state_ix)])
    elseif ~LEGACY && ~INTER_BSS && ~NON_SRG && SRG
       power_detection_threshold = wlans(wlan_ix).srg_obss_pd; 
       %disp(['    - SRG TRANSMISSION DETECTED in STATE ' num2str(state_ix)])
    elseif LEGACY
       power_detection_threshold = wlans(wlan_ix).cca;
       %disp(['    - LEGACY TRANSMISSION DETECTED in STATE ' num2str(state_ix)])
    else 
       power_detection_threshold = wlans(wlan_ix).cca;
       %disp(['    - NO TRANSMISSION DETECTED in STATE ' num2str(state_ix)])
    end  
    
end

