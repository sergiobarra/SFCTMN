%%% WLAN CTMC Analysis
%%% Author: Sergio Barrachina (sergio.barrachina@upf.edu)
%%% File description: function for plotting CTMCs

function [labels_ctmc] = plot_ctmc( S, num_wlans, num_channels_system, plot_title, Q_logical)
    %PLOT_CTMC plots the CTMC corresponding to the bunch of states entered
    % Input:
    %   - S: states matrix (states x wlans x channels)
    %   - num_wlans: number of WLANs in the system
    %   - num_channels: number of channels in the system
    %   - plot_title: title of the plot figure
    %   - Q_logical: logical transition matrix
    % Output:
    %   - labels_ctmc: array of node labels    
    
    load('constants.mat');  % Load constants into workspace
    
    num_columns_ctmc = num_wlans + 1;                   % Number of columns in the CTMC graph
    labels_ctmc{size(S,1)} = [];                        % Labels of the CTMC states
    labels_ctmc{1} = 'Empty (s1)';                      % Label of first state (s1) is "Empty"
    
    % Get positions of CTMC nodes
    pos_ctmc_nodes = zeros(2,size(S,1));                % Position of CTMC nodes
    for s = 2 : size(S,1)   % foreach state in S
        min_max_channels = zeros(num_wlans,2);          % Min and max channel being used by WLANs in state s
        label_string = '';
        for n = 1 : num_wlans   % foreach wlan
            for c = 1 : num_channels_system
                if S(s,n,c) == true     % If channel c being used by WLAN n in state s
                    pos_ctmc_nodes(1,s) = pos_ctmc_nodes(1,s) + 1;  % Set X position (column)
                    ch_range = find(S(s,n,:) == true);              % Channel range being used by WLAN n in state s 
                    min_max_channels(n,:) = [ch_range(1) ch_range(end)];
                    break
                end
            end

            if min_max_channels(n,1) ~= 0 % If WLAN is transmitting in this state (i.e., min channel used must be true)
                % Add WLAN and range to state label
                label_string = strcat(label_string,... 
                    [LABELS_DICTIONARY(n) '_{' num2str(min_max_channels(n,1)) '}^'  num2str(min_max_channels(n,2))]);
            else % If WLAN is unactive
                label_string = strcat(label_string, '');
            end        
        end
        labels_ctmc{s} = strcat(label_string, ['(s' num2str(s) ')']);   % Include state identifier in the label
    end

    % num_nodes_per_colum is the number of nodes per CTMC column (states in a given colum have same number of active WLANs
    num_nodes_per_colum = zeros(1,num_columns_ctmc);    
    for c = 1 : num_columns_ctmc
        num_nodes_per_colum(1,c) = sum(pos_ctmc_nodes(1,:) == c - 1);
    end
    aux_ix_per_wlan = zeros(1,num_columns_ctmc);    % Auxiliar index for determining the Y position in each column
    for s = 1 : size(S,1)
        aux_ix_per_wlan(1,pos_ctmc_nodes(1,s)+1) = aux_ix_per_wlan(1,pos_ctmc_nodes(1,s)+1) + 1; 
        k = aux_ix_per_wlan(1,pos_ctmc_nodes(1,s)+1);
        n = num_nodes_per_colum(1,pos_ctmc_nodes(1,s)+1);
        pos_ctmc_nodes(2,s) = -k + ((n + 1) / 2);
    end

    % Plot CTMC
    if isempty(Q_logical)   % If no transition rates provided, plot just states
        figure
        scatter(pos_ctmc_nodes(1,:),pos_ctmc_nodes(2,:), CTMC_NODE_SIZE, 'MarkerEdgeColor', CTMC_NODE_BORDER_COLOR,...
                      'MarkerFaceColor',CTMC_NODE_FILL_COLOR_NOT_FEASIBLE, 'LineWidth', CTMC_NODE_BORDER_WEIGHT);  
    else    % If transition rates is provided, plot states and edges (arrows)
        figure
        hold on;
        delta_y = 0.05;
        
        
        % Plot nodes
        for s = 1:size(S,1)
            if sum(Q_logical(s,:)) ~= 0 % Feasible state
                scatter(pos_ctmc_nodes(1,s),pos_ctmc_nodes(2,s), CTMC_NODE_SIZE, 'MarkerEdgeColor', CTMC_NODE_BORDER_COLOR,...
                  'MarkerFaceColor',CTMC_NODE_FILL_COLOR_FEASIBLE, 'LineWidth', CTMC_NODE_BORDER_WEIGHT);
            else
                scatter(pos_ctmc_nodes(1,s),pos_ctmc_nodes(2,s), CTMC_NODE_SIZE, 'MarkerEdgeColor', CTMC_NODE_BORDER_COLOR,...
                  'MarkerFaceColor',CTMC_NODE_FILL_COLOR_NOT_FEASIBLE, 'LineWidth', CTMC_NODE_BORDER_WEIGHT);
            end
        end 
        
        % Plot transition arrows
        for s_origin = 1:size(S,1)
            for s_destination = 1:size(S,1)
                if Q_logical(s_origin, s_destination) == BACKWARD_TRANSITION
                    arrow([pos_ctmc_nodes(1,s_origin), pos_ctmc_nodes(2,s_origin) + delta_y],...
                        [pos_ctmc_nodes(1,s_destination), pos_ctmc_nodes(2,s_destination) + delta_y],...
                        CTMC_ARROWHEAD_SIZE, 'EdgeColor','r','FaceColor','r');
                elseif Q_logical(s_origin, s_destination) == FORWARD_TRANSITION
                    arrow([pos_ctmc_nodes(1,s_origin), pos_ctmc_nodes(2,s_origin) - delta_y],...
                        [pos_ctmc_nodes(1,s_destination), pos_ctmc_nodes(2,s_destination) - delta_y],...
                        CTMC_ARROWHEAD_SIZE, 'EdgeColor','b','FaceColor','b');
                end
            end
        end 
        
    end
    
    % Final processing of CTMC figure
    text(pos_ctmc_nodes(1,:), pos_ctmc_nodes(2,:), labels_ctmc);
    min_x = -1/2;
    max_x = num_wlans + 1;
    min_y = min( pos_ctmc_nodes(2,:)) - 1;
    max_y = max( pos_ctmc_nodes(2,:)) + 1;
    xlim([min_x max_x]);
    ylim([min_y max_y]);
    title(plot_title);
    set(gca,'xticklabel',[]);
    set(gca,'yticklabel',[]);
    grid on;
    drawnow     % Plot graphic during execution time
    
end

