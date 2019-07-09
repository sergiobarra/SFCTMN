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

function [ type_neighboring_wlans ] = identify_neighboring_wlans( wlans, wlan_ix )
    %CHECK_WLAN_TYPE checks if the type of wlan transmitting in a given state
    % Input:
    %   - wlans: array of structures with wlans info
    %   - wlan_ix: index of the potentially inteferred WLAN
    %   - neighboring_wlan_ix: index of the potentially interfering WLAN
    % Output:
    %   - wlan_type: integer indicating the type of WLAN
    
    load('constants_sfctmn_framework.mat');  % Load constants into workspace
    
    type_neighboring_wlans =  zeros(1, size(wlans, 2));                   
    % Iterate for each potential OBSS in the possible state 
    for i = 1 : size(wlans, 2)
       if i ~= wlan_ix
           type_neighboring_wlans(i) = check_wlan_type(wlans, wlan_ix, i);
       else
           type_neighboring_wlans(i) = -1; % To indicate that it is the same WLAN
       end
    end
    
end

