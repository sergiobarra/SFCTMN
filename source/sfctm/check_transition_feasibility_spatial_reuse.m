function [ feasible ] = check_transition_feasibility_spatial_reuse( wlans, PSI_cell, ...
    Power_PSI_cell, Power_Detection_PSI_cell, source_state_ix, dest_state_ix, wlan_ix )

    %CHECK_STATE_FEASIBILITY checks if a given state is feasible or not
    %   - wlans: array of structures with wlans info
    %   - PSI_cell: 
    %   - Power_PSI_cell: 
    %   - Power_Detection_PSI_cell: 
    %   - source_state_ix: index of the source state
    %   - dest_state_ix: index of the destination state
    %   - wlan_ix: index of the wlan attempting to access to state "state_ix"
    % Output:
    %   - feasible: boolean indicating that a state is feasible (1) or not (0)
    
    feasible = false;
   
    % Find active WLANs in state "state_ix"
    active_wlans = find(PSI_cell{source_state_ix}>0);    
    pd_thresholds = zeros(1,4); % In order to store all the possible PD threshold associated to ongoing transmissions
    % If there is more than one active WLAN, check if the dest. state is feasible
    if active_wlans >= 1
        % Iterate for each active wlan different than "wlan_ix"
        for ix = 1 : size(active_wlans)
            if wlan_ix ~= active_wlans(ix)
               % In case SRG is activated
               if wlans(wlan_ix).srg >= 0 && wlans(active_wlans(ix)).srg >= 0  
                   % Same SRG case
                   if wlans(wlan_ix).srg == wlans(active_wlans(ix)).srg
                        pd_thresholds(3) = wlans(wlan_ix).srg_obss_pd;
                   % Different SRG case
                   else
                       pd_thresholds(4) = wlans(wlan_ix).non_srg_obss_pd;
                   end
               % In case BSS color is activated, but not SRG
               elseif wlans(wlan_ix).bss_color >= 0 && wlans(active_wlans(ix)).bss_color >= 0 
                   % Same BSS color case
                   if wlans(wlan_ix).bss_color == wlans(active_wlans(ix)).bss_color
                       pd_thresholds(1) = wlans(wlan_ix).cca;
                   % Different BSS color case
                   else
                       pd_thresholds(2) = wlans(wlan_ix).non_srg_obss_pd;
                   end
               % Legacy capabilities
               else 
                   pd_thresholds(1) = wlans(wlan_ix).cca;
               end
            end
        end          
        % Check if the PD condition is accomplished for all the ongoing transmissions (use the minimum of all the gathered thresholds)
        if Power_Detection_PSI_cell{dest_state_ix}(wlan_ix) <=  min(pd_thresholds) && ...
            Power_PSI_cell{source_state_ix}(wlan_ix) < Power_Detection_PSI_cell{dest_state_ix}(wlan_ix)           
            feasible = true;
        end
    else 
        feasible = true;
    end
            
end