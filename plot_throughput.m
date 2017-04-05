%%% WLAN CTMC Analysis
%%% Author: Sergio Barrachina (sergio.barrachina@upf.edu)
%%% File description: function for plotting WLANs throughput

function [ ] = plot_throughput( throughput, num_wlans, plot_title )
    %PLOT_THROUGHPUT plots the throughput of every WLAN in the system
    % Input:
    %   - throughput: array whose element w is the average throughput of WLAN w
    %   - num_wlans: number of WLANs in the system
    
    load('constants.mat');  % Load constants into local workspace
    
    figure
    hold on
    
    % WLANs throughput
    for wlan_ix = 1 : num_wlans
        ticks_labels(wlan_ix, 1) = LABELS_DICTIONARY(wlan_ix);  % Add WLAN label
        h = bar(wlan_ix, throughput(wlan_ix));                  % Plot histogram
        set(h, 'FaceColor', COLORS_DICTIONARY(wlan_ix,:))
    end
    
    % Include average throughput
    average_throughput = sum(throughput)/num_wlans;
    ticks_labels(num_wlans + 1, 1) = 'm';
    h = bar(num_wlans + 1, average_throughput);                  
    set(h, 'FaceColor',  [0.5 0.5 0.5]);

    xticklabels(ticks_labels)
    ticks_position = 1 : num_wlans + 1;
    set(gca, 'XTick',ticks_position, 'XTickLabel',ticks_labels)
    grid on
    ylabel('Trhoughput [Mbps]')
    title(plot_title)
    drawnow     % Plot graphic during execution time
end