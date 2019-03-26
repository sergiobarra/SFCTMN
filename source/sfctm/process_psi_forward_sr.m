function new_psi_forward = process_psi_forward_sr(psi_forward, PSI_cell, current_state_ix, wlans, wlan_ix, wlans_types )
%PROCESS_PSI_FORWARD_SPATIAL_REUSE Summary of this function goes here
%   Detailed explanation goes here

    new_psi_forward = [];
    
    num_possible_forward_states = size(psi_forward, 2);
    
%     if num_possible_forward_states == 1
%         
%                 
%     else 

% disp('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%')
% disp('Check forward states')
        for ix = 1 : num_possible_forward_states    % For each possible forward state

            %disp(['     * state ' num2str(possible_forward_states(ix))])

            % Possible forward state
            psi_possible_ix = psi_forward(ix);
            state_feasible = false;

            %disp(['* psi_possible_ix ' num2str(psi_possible_ix)])
            %PSI_cell{current_state_ix}
            %PSI_cell{psi_possible_ix}

            %disp(['* wlans_types ' num2str(wlans_types(wlan_ix, :))])

            % Difference between current state and feasible state
            difference_between_states = PSI_cell{psi_possible_ix} - PSI_cell{current_state_ix};
            new_wlan_type = sum(difference_between_states);

            wlans_aux = [];
            for w_ix = 1 : size(wlans, 2)
                if PSI_cell{current_state_ix}(w_ix) > 0 && w_ix ~= wlan_ix
                    wlans_aux = [wlans_aux w_ix];
                end
            end

            % First check
            %disp(['     - wlans_types = ' num2str(wlans_types(wlan_ix, :)) ' / new_wlan_type = ' num2str(new_wlan_type)])
            
            if sum(wlans_types(wlan_ix, :) == new_wlan_type) > 0   
                %disp('   + First check passed!')
                % Second check
                %disp(['     - wlans_aux = ' num2str(wlans_aux) ' / new_wlan_type = ' num2str(new_wlan_type)])
                if sum(wlans_types(wlan_ix, wlans_aux) == new_wlan_type) > 0     
                %    disp('    + Second check passed!')
                    if PSI_cell{psi_possible_ix}(wlans_aux) ~= PSI_cell{psi_possible_ix}(wlan_ix)
                %        disp('    + Third check passed!')
                        state_feasible = true;      
                    end
                end
            end       


    %         if wlans_types(new_wlan_ix) == new_wlan_type || sum(PSI_cell{psi_possible_ix} > 1) == 0
    %             state_feasible = true;
    %         end
    % 
    %         % Second check
    %         new_state_transmitting_wlans = size(find(PSI_cell{psi_possible_ix} > 0), 1);% == size(wlans,2) - 1
    %         if new_state_transmitting_wlans == 1 && sum(wlans_types == new_wlan_type) > 0 
    %             state_feasible = true;
    %         end
    % 
    %         if new_state_transmitting_wlans > 0
    %             [~, new_wlan_ix_aux] = find(PSI_cell{current_state_ix} > 0);
    %             if wlans_types(new_wlan_ix_aux) == new_wlan_type
    %                 state_feasible = true;
    %             end                
    %         end
    %             
    % %             %if new_state_transmitting_wlans == 1 
    %         if sum(wlans_types == new_wlan_type) > 0 
    %             if PSI_cell{psi_possible_ix}(wlan_ix) == new_wlan_type  
    %                 state_feasible = true;
    %             end
    %         end

                % Third check


    %         disp('===================')
    %         PSI_cell{current_state_ix}
    %         PSI_cell{psi_possible_ix}
    %         PSI_cell{psi_possible_ix} - PSI_cell{current_state_ix}
    %         wlan_ix
    %         PSI_cell{psi_possible_ix}(wlan_ix)
    %         wlans_types
    %         new_wlan_type
    %         new_wlan_ix
    %         state_feasible
    %         disp('===================')


            if state_feasible
                new_psi_forward = [new_psi_forward psi_possible_ix];
            end

        end
%     end

end