function [states,ww] = create_wlan_states(primary, minmax, max_c, widths)
    % create_wlan_states(primary, max_w, minmax, max_c, widths)
    % primary: primary position
    % minmax boundary positions (ex [2 5])
    % max_c: max number of channel (ex: 19)
    % max_w: max width for this wlan (ex: 4)

    jumps_two = false; % it's a parameter that tell if I can occupy any contiguous
                       % position or only starting with right multiples

    if numel(minmax) == 1
        minmax = [minmax minmax];
    end
    max_w = (minmax(2)-minmax(1)+1);
    if nargin < 4
        widths = 2.^(0:log2(max_w));
    end
    if nargin < 3
        max_c = 19;
    end

    states(1,:) = false(1,max_c);
    ww = 0;
    
    % LOG2 Channel access (Alessandro's old code)
%     for i = 1:numel(widths)
%         w = widths(i);
%         for j = (primary - w + 1):primary
%             if ((j>=1) && (j <= max_c) && (j+w-1<=max_c) && (j>=minmax(1)) && (j+w-1<=minmax(2)) ) %(~jumps_two||w==1||~mod(j-1,2))&&
%                 states(end+1,j:(j+w-1)) = true;
%                 ww(end+1) = w;
%             end
%         end
%     end
    
    % SERGIO NEW CODE for just IEEE 802.11 channels
    for i = 1:numel(widths)
        w = widths(i);
        for j = (primary - w + 1):primary
            if ((j>=1) && (j <= max_c) && (j+w-1<=max_c) && (j>=minmax(1)) && (j+w-1<=minmax(2)))
                
                candidate_range = j:(j + w - 1);
                num_channels_candidate = (j + w - 1) - j + 1;
                is_acceptable_candidate_range = true;

                % Determine if candidate range complies with IEEE 802.11 channelization constraints
                switch num_channels_candidate

                    case 1
                        % candidate range remains the same

                    case 2

                        if isequal(candidate_range, 2:3) || isequal(candidate_range, 4:5) ||...
                                isequal(candidate_range, 6:7)
                            is_acceptable_candidate_range = false;
                        end

                    case 4

                        if ~(isequal(candidate_range, 1:4) || isequal(candidate_range, 5:8))
                            is_acceptable_candidate_range = false;
                        end

                    case 8
                        % candidate range remains the same

                    otherwise

                end

                if is_acceptable_candidate_range
                    states(end + 1, j : (j + w - 1)) = true;
                    ww(end + 1) = w;
                end
            end
        end
    end

    
    
end







