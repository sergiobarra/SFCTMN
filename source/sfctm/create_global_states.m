function glob = create_global_states(wlan_struct)
    % ALESSANDRO CODE

N = numel(wlan_struct);
max_c = size(wlan_struct(1).states,2);

for wlan=1:N
    ss{wlan} = 1:size(wlan_struct(wlan).states,1);
end

toremove=[];
states = setprod(ss{:});

order = zeros(1,size(states,1));
for i=1:size(states,1)
%     disp(['  - state ' num2str(i) ' of ' num2str(size(states,1))])
    t = false(N,max_c);
    for wlan=1:N
        t(wlan,:) = wlan_struct(wlan).states(states(i,wlan),:);
    end
    if any(sum(t)>1)
        toremove = [toremove i];
%         disp('removing:')   
%         disp(t)
    else
        order(i) = sum(any(t,2));
    end
end

% states(toremove,:)=[];
% order(toremove) = [];
glob.states = states;
glob.order = order;       