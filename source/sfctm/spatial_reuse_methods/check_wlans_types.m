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

function [ wlans_types ] = check_wlans_types( wlans )
    %CHECK_WLAN_TYPE checks if the type of wlan transmitting in a given state
    % Input:
    %   - wlans: array of structures with wlans info
    %   - wlan_ix: index of the potentially inteferred WLAN
    %   - neighboring_wlan_ix: index of the potentially interfering WLAN
    % Output:
    %   - wlan_type: integer indicating the type of WLAN
    
    %load('constants_sfctmn_framework.mat');  % Load constants into workspace
    
    wlans_types = -1 * ones(size(wlans, 2), size(wlans, 2));
        
    for i = 1 : size(wlans, 2)
        for j = 1 : size(wlans, 2)
            if i ~= j
                if wlans(i).non_srg_activated
                    if wlans(j).srg == wlans(i).srg
                        wlans_types(i, j) = 3;
                    elseif wlans(j).srg ~= wlans(i).srg
                        wlans_types(i, j) = 2; 
                    end
                else 
                    wlans_types(i, j) = 1;
                end
            end
        end
    end     
    
end