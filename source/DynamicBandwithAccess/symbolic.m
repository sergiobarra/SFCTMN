reset(symengine)
clear
l=100;
u1=20;
u2=41;
syms a1 a2 positive
assumeAlso(a1,'real')
assumeAlso(a2,'real')
assumptions
a2 = 1-a1
q = [-l*a1-l*a2-l,l*a1,l*a2,l,0;u1,-u1-l,0,0,l;u2,0,-u2,0,0;u1,0,0,-u1-l,l;0,u1,0,u1,-2*u1]
%q  = [-(l+l),]
p = mrdivide([zeros(1,size(q,1)) 1],[q ones(size(q,1),1)])
s0=subs(p,a1,0.0)

SA=s0(2)*u1+s0(3)*u2+s0(5)*u1;
SB=s0(4)*u1+s0(5)*u1;

double([SA SB SA+SB])

s05=subs(p,a1,0.5)

SA=s05(2)*u1+s05(3)*u2+s05(5)*u1;
SB=s05(4)*u1+s05(5)*u1;

double([SA SB SA+SB])

s1=subs(p,a1,1.0)

SA=s1(2)*u1+s1(3)*u2+s1(5)*u1;
SB=s1(4)*u1+s1(5)*u1;

double([SA SB SA+SB])


through_states = [p(2)*u1+p(3)*u2+p(5)*u1,p(4)*u1+p(5)*u1];
through = sum(through_states)
fairn = sum(log(through_states))
% choose what to optimise
f = -fairn;


x = [a1] % in general it should be columns [a1;a2]
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
c = [c1 c2];

options = optimoptions('fmincon','Algorithm','interior-point',...
    'Display','final');
% fh3 = objective without gradient or Hessian
fh3 = matlabFunction(f,'vars',{x});
% constraint without gradient:
constraint = matlabFunction(c,[],'vars',{x});
[xfinal,fval,exitflag,output2] = fmincon(fh3,[0.5],...
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
	[xfinal,fval,exitflag,output] = fmincon(fh2,[0.5],...
	    [],[],[],[],[],[],constraint,options)
		
		
		sprintf(['There were %d iterations using gradient' ...
		    ' and Hessian, but %d without them.'],...
		    output.iterations,output2.iterations)
		sprintf(['There were %d function evaluations using gradient' ...
		    ' and Hessian, but %d without them.'], ...
		    output.funcCount,output2.funcCount)