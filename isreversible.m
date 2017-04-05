function [answer, dist] = isreversible(m,p,error)
if nargin < 3
    error = 1e-8;
end
answer = true;
dist = 0;
N = length(p);
    for i = 1:N
        for j = 1:N
            d = abs(p(i)*m(i,j)-p(j)*m(j,i));
            dist = dist + d;
            if d > error
                answer = false;
            end
        end
    end          
end