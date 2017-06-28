function [ wlans, num_channels_system, num_wlans ] = generate_wlans( wlan_input_filename )
    %GENERATE_WLANS generate the wlan structures given a WLAN input .csv file
    % Input:
    %   - wlan_input_filename: path of the .csv file
    % Output:
    %   - wlans: WLANs structures
    %   - num_channels_system: number of basic channels in the system
    
    load('constants.mat');  % Load constants into workspace
    
    
    % Generate wlan structures
    input_data = load(wlan_input_filename);  
    wlans = []; % Array of structures containning wlans info
    num_wlans = length(input_data(:,1));    % Number of WLANs (APs)
    num_channels_system = 0;                % Number of channels in the system (is determined the most right channel used)

    for w = 1 : num_wlans

        wlans(w).code = input_data(w,INPUT_FIELD_IX_CODE);          % Pick WLAN code
        wlans(w).primary = input_data(w,INPUT_FIELD_PRIMARY_CH);    % Pick primary channel
        wlans(w).range = [input_data(w,INPUT_FIELD_LEFT_CH) input_data(w,INPUT_FIELD_RIGHT_CH)];  % pick range
        wlans(w).position_ap = [input_data(w,INPUT_FIELD_POS_AP_X) input_data(w,INPUT_FIELD_POS_AP_Y)...
            input_data(w,INPUT_FIELD_POS_AP_Z)];                       % Pick AP positions
        wlans(w).position_sta = [input_data(w,INPUT_FIELD_POS_STA_X) input_data(w,INPUT_FIELD_POS_STA_Y)...
            input_data(w,INPUT_FIELD_POS_STA_Z)];                       % Pick STA positions
        wlans(w).tx_power = input_data(w,INPUT_FIELD_TX_POWER);     % Pick transmission power
        wlans(w).cca = input_data(w,INPUT_FIELD_CCA);               % Pick CCA level
        wlans(w).lambda = input_data(w,INPUT_FIELD_LAMBDA);         % Pick lambda
        wlans(w).states = [];   % Instantiate states for later use          
        wlans(w).widths = [];   % Instantiate acceptable widhts item for later use

        if(num_channels_system <  wlans(w).range(2))
            num_channels_system = wlans(w).range(2);         % update number of channels present in the system
        end

    end
    
end

