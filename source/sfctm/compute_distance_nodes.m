function [distance_ap_ap, distance_ap_sta] = compute_distance_nodes(wlans)
% compute_distance_nodes computes the distance between all the nodes in a
% "wlans" object
%   OUTPUT: 
%       * distance_ap_ap - matrix with distances between Access Points 
%       * distance_ap_sta - matrix with distances between APs and stations
%   INPUT: 
%       * wlans - object containing information of the overlapping WLANs

    n_wlans = size(wlans,2);
    
    distance_ap_ap = zeros(n_wlans, n_wlans);
    distance_ap_sta = zeros(n_wlans, n_wlans);
    
    for i= 1 : n_wlans
          
        for j = 1 : n_wlans

            distance_ap_ap(i,j) = sqrt((wlans(i).position_ap(1) - wlans(j).position_ap(1))^2 + ...
                            (wlans(i).position_ap(2) - wlans(j).position_ap(2))^2 + ...
                            (wlans(i).position_ap(3) - wlans(j).position_ap(3))^2);
                        
            distance_ap_sta(i,j) = sqrt((wlans(i).position_ap(1) - wlans(j).position_sta(1))^2 + ...
                            (wlans(i).position_ap(2) - wlans(j).position_sta(2))^2 + ...
                            (wlans(i).position_ap(3) - wlans(j).position_sta(3))^2);
        
        end
        
    end

end