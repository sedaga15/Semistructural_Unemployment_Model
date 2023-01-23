function [m,p,mss] = readmodel_est2()
% PARAMETRIZE AND SOLVE THE MODEL

%% Parameters

par = load("params_est.mat");

%% === Solving the model === 
% 1) command 'model' reads the text file 'model.model' (contains the model's equations), 
% assigns the parameters and steady state values from database 'p' (see above),
% and transforms the model for the matrix algebra. Transformed model is written in the object 'm'. 
m = model('model.model','linear=',true,'assign',par.par);

% 2) command 'solve' takes the model object 'm' and solves the model
% for its reduced form (Blanchard-Kahn algorithm). The reduced form is again written in the object 'm'   
m = solve(m);

% 3) command 'sstate' further takes the model object 'm', calculates the model's
% steady-state and writes everything back in the object 'm'. 
m = sstate(m);

%% === Information which can be extracted from the model object === 
% a) extract steady-state values
mss = get(m,'sstate');

p = get(m,'params');

% b) extract comments on all variables and parameters
desc = get(m,'desc');

% c) extract list of variables'/parameters' names
ynames = get(m,'yList'); %- measuments variables
xnames = get(m,'xList'); %- transition variables
enames = get(m,'eList'); %- shocks
enames = get(m,'pList'); %- parameters

% d) extract list of equations
yeqtn = get(m,'yEqtn'); %- measuments equations
xeqtn = get(m,'xEqtn'); %- transition equations

% e) a database with current std deviations of shocks
std = get(m,'std');  

% f) maximum lead/lag in the model
maxlead = get(m,'maxLead');
maxlag = get(m,'maxLag');

% g) to find out more, type: help model.get


%% === Check steady state === 
[flag,discrep,eqtn] = chksstate(m,'error',false);

if ~flag
  error('Equation fails to hold in steady state: "%s"\n', eqtn{:});
end