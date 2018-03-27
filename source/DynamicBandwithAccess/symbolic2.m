reset(symengine)
clear
l=10000;
u1=20;
u2=40;
syms a1 a2 b1 b2 g1 g2 positive
assumeAlso(a1,'real')
assumeAlso(a2,'real')
assumeAlso(b1,'real')
assumeAlso(b2,'real')
assumeAlso(g1,'real')
assumeAlso(g2,'real')
assumptions
a2 = 1-a1
b2 = 1-b1
g2 = 1-g1


q  = [0,a1*l,a2*l,b1*l,b2*l,0,0;u1,0,0,0,0,l,0;u2,0,0,0,0,0,l;u1,0,0,0,0,g1*l,g2*l;u2,0,0,0,0,0,0;0,u1,0,u1,0,0,0;0,0,u1,u2,0,0,0];
q = q - diag(sum(q,2)); %add diagonal terms

p = mrdivide([zeros(1,size(q,1)) 1],[q ones(size(q,1),1)])





through_states = [p(2)*u1+p(3)*u2+p(6)*u1+p(7)*u2, p(4)*u1+p(5)*u2+p(6)*u1+p(7)*u1];
through = sum(through_states)
fairn = sum(log(through_states))
jain = (sum(through_states)^2)/(2*sum(through_states.^2))
% choose what to optimise
f = -through;


x = [a1;b1;g1] % in general it should be columns [a1;a2]
gradf = jacobian(f,x).';
hessf = jacobian(gradf,x);


% unconstrained version
%fh = matlabFunction(f,gradf,hessf,'vars',{x});
%starting_point = 0.5; %in general it should be columns [0.5;0.5]
%options = optimoptions('fminunc', ...
%    'SpecifyObjectiveGradient', true, ...
%    'HessianFcn', 'objective', ...
%    'Algorithm','trust-region', ...
%    'Display','final');
%[xfinal,fval,exitflag,output] = fminunc(fh,starting_point,options)


%constraint
c1 = a1 - 1;
c2 = -a1; %not sure if needed since we assumed positive
c3 = b1 -1;
c4 = -b1;
c5 = g1 - 1;
c6 = -g1;
c = [c1 c2 c3 c4 c5 c6];

options = optimoptions('fmincon','Algorithm','interior-point',...
    'Display','final');
% fh3 = objective without gradient or Hessian
fh3 = matlabFunction(f,'vars',{x});
% constraint without gradient:
constraint = matlabFunction(c,[],'vars',{x});
[xfinal,fval,exitflag,output2] = fmincon(fh3,[0;0;0],...
    [],[],[],[],[],[],constraint,options)




gradc = jacobian(c,x).'; % transpose to put in correct form
constraint = matlabFunction(c,[],gradc,[],'vars',{x});
hessc1 = jacobian(gradc(:,1),x); % constraint = first c column
hessc2 = jacobian(gradc(:,2),x);

hessfh = matlabFunction(hessf,'vars',{x});
hessc1h = matlabFunction(hessc1,'vars',{x});
hessc2h = matlabFunction(hessc2,'vars',{x});
myhess = @(x,lambda)(hessfh(x) + ...
    lambda.ineqnonlin(1)*hessc1h(x) + ...
    lambda.ineqnonlin(2)*hessc2h(x));
	options = optimoptions('fmincon', ...
	    'Algorithm','interior-point', ...
	    'SpecifyObjectiveGradient',true, ...
	    'SpecifyConstraintGradient',true, ...
	    'HessianFcn',myhess, ...
	    'Display','final');
	% fh2 = objective without Hessian
	fh2 = matlabFunction(f,gradf,'vars',{x});
	[xfinal,fval,exitflag,output] = fmincon(fh2,[0.5;0.5;0.5],...
	    [],[],[],[],[],[],constraint,options)
		
		
		sprintf(['There were %d iterations using gradient' ...
		    ' and Hessian, but %d without them.'],...
		    output.iterations,output2.iterations)
		sprintf(['There were %d function evaluations using gradient' ...
		    ' and Hessian, but %d without them.'], ...
		    output.funcCount,output2.funcCount)


% global optimisation			simulated annealing
options = optimoptions('simulannealbnd')
options.FunctionTolerance = 1e-10;
options.InitialTemperature = 10000;
g = matlabFunction(f,'vars',{[a1,b1,g1]})
simulannealbnd(g,[0.5,0.5,0.5],[0,0,0],[1,1,1])