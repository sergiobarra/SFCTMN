function [m,wlan,glob,tochange] = create_matrix_dbca(wlan,n_chan,onlymax,selfloop)


if nargin == 1
    n_chan = 19;
end

for i = 1:numel(wlan)
    [wlan(i).states wlan(i).widths] = create_wlan_states(wlan(i).primary,wlan(i).range,n_chan);
    for j = 1:size(wlan(i).states,1)
        if wlan(i).widths(j) > 0
            wlan(i).state_mu(j) = wlan(i).mu(log2(wlan(i).widths(j))+1);
        end
    end
end
glob = create_global_states(wlan);

[m,dummy,wlan,glob] = explore_graph(wlan,glob,onlymax,selfloop);
end
