function [matrix,visited,wlan_struct,glob_struct] = explore_graph(wlan_struct,glob_struct,onlymax,selfloop)

if nargin < 3
    onlymax = true;
end
if nargin < 4
    selfloop = false;
end

M = size(glob_struct.states,1);
matrix = zeros(M,M);
increase_matrix = zeros(M,M); %this matrix holds which leads to an increase
visited = logical(eye(M,M)); %which edges has been visited.
visited_states = false(1,M);
current.state_idx = 1;
current.state = glob_struct.states(current.state_idx,:);
current.order = glob_struct.order(current.state_idx);
NN = numel(wlan_struct);
C = size(wlan_struct(1).states,2);
verbose = 0;
countcalls=0;
recursive_explore(current);
postprocess();
    
%keyboard


    function recursive_explore(curr)
        visited_states(curr.state_idx)=true;
        countcalls = countcalls + 1;
%         disp(find(abs(glob_struct.order-curr.order)==1))
%         disp([find(glob_struct.order-curr.order==1) find(glob_struct.order-curr.order==-1)])
%         isequal(sort(find(abs(glob_struct.order-curr.order)==1)),sort([find(glob_struct.order-curr.order==1) find(glob_struct.order-curr.order==-1)]))
%         for n=[find(glob_struct.order-curr.order==1) find(glob_struct.order-curr.order==-1)] % for all neighbours (first going right to improve recursion)
        for n=find(abs(glob_struct.order-curr.order)==1) % for all neighbours
            next.state_idx = n;
            next.state = glob_struct.states(next.state_idx,:);
            next.order = glob_struct.order(next.state_idx);
%             if next.state_idx == 10
%                 verbose = 1;
%             else
%                 verbose = 0;
%             end
            if ~visited(curr.state_idx,next.state_idx)
                visited(curr.state_idx, next.state_idx) = true;
                    dif = curr.state~=next.state; %in what they differ
                    if  sum(dif) == 1 %if they differ only for one
                        if verbose==1
                            disp(['considering from' num2str(curr.state_idx) ' that is: ' num2str(curr.state) 'to ' num2str(next.state_idx) ' that is:' num2str(next.state)] )
                            disp([wlan_struct(1).states(curr.state(1),:); wlan_struct(2).states(curr.state(2),:)])% ;wlan_struct(3).states(curr.state(3),:)])
                            disp('to:')
                            disp([wlan_struct(1).states(next.state(1),:); wlan_struct(2).states(next.state(2),:)])%;wlan_struct(3).states(next.state(3),:)])
                        end
                        changing_wlan = find(dif==1);
                        others = find(dif~=1);
                        if next.order - curr.order == 1 % going right, have to check it's max
                            tempmat = zeros(NN-1,C);
                            for kkk = 1:numel(others)
                                kk = others(kkk);
                                tempmat(kkk,:) = wlan_struct(kk).states(curr.state(kk),:);
                            end
                            ttt = sum(tempmat,1)>0;
                            maxw = 0;
                            for jj=1:size(wlan_struct(changing_wlan).states,1)
                                if all(wlan_struct(changing_wlan).states(jj,:)+ttt<=1) % no intersection
                                    maxw = max(maxw,sum(wlan_struct(changing_wlan).states(jj,:)));
                                end
                            end
%                              disp(maxw)
%                              if curr.state_idx ==3 && next.state_idx == 9
%                                  disp('s')
%                              end
                            if maxw == sum(wlan_struct(changing_wlan).states(next.state(changing_wlan),:)) || ~onlymax % going to max
                                matrix(curr.state_idx, next.state_idx) = wlan_struct(changing_wlan).lambda;
                                increase_matrix(curr.state_idx, next.state_idx) = changing_wlan;
                                if(~visited_states(next.state_idx));recursive_explore(next);end
                            else
                                if ( verbose==1);disp('not to maximum');end
                            end
                        else %going left
                                matrix(curr.state_idx, next.state_idx) = wlan_struct(changing_wlan).state_mu(curr.state(changing_wlan));
                                if(~visited_states(next.state_idx));recursive_explore(next);end
                        end
                        
                    else
%                         if (next.order ==1 &&  verbose==1);disp('discarded');end
                    end
            end
      
        end    
    end
    function postprocess()
	for i=1:M
		for j=1:numel(wlan_struct)
            if sum(increase_matrix(i,:)==j) >0
                if selfloop
                    matrix(i,(increase_matrix(i,:)==j)) = matrix(i,(increase_matrix(i,:)==j))./sum((increase_matrix(1,:)==j)); %normalisation multiple outputs 
                else
                    matrix(i,(increase_matrix(i,:)==j)) = matrix(i,(increase_matrix(i,:)==j))./sum((increase_matrix(i,:)==j)); %normalisation multiple outputs
                end
            end
		end
	end
        toremove=[];
        for i=1:M
            if ~any(matrix(i,:))
                toremove=[toremove i];
            end
        end
        glob_struct.states(toremove,:)=[];
        glob_struct.order(toremove)=[];
        matrix(toremove,:)=[];
        matrix(:,toremove)=[];
        visited(toremove,:)=[];
        visited(:,toremove)=[];
        M = size(glob_struct.states,1);
        for i=1:M
            matrix(i,i) = -sum(matrix(i,:));
        end
    end
% disp(countcalls)
end
