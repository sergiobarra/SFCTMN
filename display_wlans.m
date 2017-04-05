%%% Author: Sergio Barrachina (sergio.barrachina@upf.edu)
%%% File description: function for displaying WLANs' input info

function [ ] = display_wlans( wlans, flag_display_wlans, flag_plot_wlans, flag_plot_ch_allocation, num_channels_system )
    %DISPLAY_WLANS displays WLANs' input info
    % Input:
    %   - wlans: array of structures with wlans info
    %   - flag_plot_wlans: flag for plotting WLANs' distribuition
    %   - flag_display_wlans: flag for displaying WLANs' info
    %   - flag_plot_ch_allocation: flag for plotting WLANs' channel allocation
    %   - num_channels_system: number of channels in the system
    
    load('constants.mat');  % Load constants into local workspace
    
    num_wlans = length(wlans);  % Number of WLANs in the system
    
    % Display WLANs' info
    if flag_display_wlans
        
        disp('WLANS info:')
        
        for wlan_ix = 1 : num_wlans

            disp(['  - wlan ' LABELS_DICTIONARY(wlans(wlan_ix).code) ':'])
            disp(['    · primary ch: '  num2str(wlans(wlan_ix).primary)])
            disp(['    · range: '  num2str(wlans(wlan_ix).range(1)) ' - ' num2str(wlans(wlan_ix).range(2))])
            disp(['    · num nodes: '  num2str(wlans(wlan_ix).num_nodes)])
            disp(['    · position: ('  num2str(wlans(wlan_ix).position(1)) ', ' num2str(wlans(wlan_ix).position(2))...
                ', ' num2str(wlans(wlan_ix).position(3)) ')'])
            disp(['    · tx power: '  num2str(wlans(wlan_ix).tx_power) ' dBm'])
            disp(['    · CCA level: '  num2str(wlans(wlan_ix).cca) ' dBm'])
        end
    end
    
    % Plot WLANs' spatial distribution
    if flag_plot_wlans
        
        figure
        hold on
        
        for wlan_ix = 1 : num_wlans
            
            % Plot AP
            scatter(wlans(wlan_ix).position(1), wlans(wlan_ix).position(2), CTMC_NODE_SIZE/2,...
                'MarkerEdgeColor',[0 0 0], 'MarkerFaceColor', COLORS_DICTIONARY(wlan_ix,:));

            % Plot communication range
            r = compute_node_com_range(PATH_LOSS_FREE_SPACE, wlans(wlan_ix).tx_power, wlans(wlan_ix).cca,...
                GAIN_TX_DEFAULT, GAIN_RX_DEFAULT, FREQUENCY);
            c = [wlans(wlan_ix).position(1) wlans(wlan_ix).position(2)];    
            t = linspace(0, 2*pi);
            x = r*cos(t) + c(1);
            y = r*sin(t) + c(2);
            p = patch(x, y, 'g');
            set(p, 'FaceColor', COLORS_DICTIONARY(wlan_ix,:), 'EdgeColor', COLORS_DICTIONARY(wlan_ix,:), 'FaceAlpha',...
                COM_RANGE_TRANSPARENCY);

            axis equal
            text(wlans(wlan_ix).position(1), wlans(wlan_ix).position(2), LABELS_DICTIONARY(wlan_ix));

        end

        grid on
        title('WLANs spatial distribution')
        xlabel('x [m]')
        ylabel('y [m]')
    end
    
    % Plot WLANs' channel allocation
    if flag_plot_ch_allocation
        
        figure
        hold on
        
        delta_ch = 1;
        delta_wlan = 1;
        offset_wlan = .1;

        x_ticks_position = 1:num_channels_system;
        y_ticks_position = 0:num_wlans - 1;

        for wlan_ix = 1 : num_wlans

            for c = wlans(wlan_ix).range(1) :  wlans(wlan_ix).range(2)

                vertex = [((c-.5) * delta_ch) ((num_wlans - wlan_ix - .5) * delta_wlan)];
                rectangle_width = delta_ch;
                rectangle_height = delta_wlan - offset_wlan;

                rectangle('Position',[vertex(1) (vertex(2) + offset_wlan) rectangle_width rectangle_height],...
                    'FaceColor', COLORS_DICTIONARY(wlan_ix,:) + [.1 .1 .1],  'LineWidth', 0.05, ...
                    'LineStyle', ':', 'EdgeColor', [0.3 0.3 0.3])                  
            end

            ticks_labels(num_wlans - wlan_ix + 1, 1) = LABELS_DICTIONARY(wlan_ix);

        end

        for wlan_ix = 1 : num_wlans

            for c = wlans(wlan_ix).range(1) :  wlans(wlan_ix).range(2)

                vertex = [((c-.5) * delta_ch) ((num_wlans - wlan_ix - .5) * delta_wlan)];
                rectangle_width = delta_ch;
                rectangle_height = delta_wlan - offset_wlan;

                if c == wlans(wlan_ix).primary
                    rectangle('Position',[vertex(1) (vertex(2) + offset_wlan) rectangle_width rectangle_height],...
                        'FaceColor', COLORS_DICTIONARY(wlan_ix,:), 'LineWidth', 2, ...
                        'LineStyle', '-', 'EdgeColor', [0.639 0.078 0.18])
                end
            end
        end

        xticks(x_ticks_position)
        yticks(y_ticks_position)
        yticklabels(ticks_labels)
        set(gca, 'YTick',y_ticks_position,'YTickLabel',ticks_labels)
        grid on
        xlim([0.5, (num_channels_system + 0.5)])
        ylim([-.5 (num_wlans -.5)])
        title('WLANs channel allocation')
        xlabel('channel index')
        drawnow     % Plot graphic during execution time
        
    end
        
end

