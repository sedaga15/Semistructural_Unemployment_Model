function [m,p,mss] = readmodel_hyst()
% PARAMETRIZE AND SOLVE THE MODEL

%% === Steady state parameters ===

% Potential output growth
p.ss_DLA_GDP_BAR = 3.3;

% Domestic inflation target
p.ss_D4L_CPI_TAR = 3; 

% Domestic real interest rate 
p.ss_RR_BAR = 3.0;

% Change in the real ER (negative number = real appreciation)
p.ss_DLA_Z_BAR = 0.0;

% Foreign inflation or inflation target
p.ss_DLA_CPI_RW = 2;

% Level of foreign real interest rate
p.ss_RR_RW_BAR = 0.50;

% Unemployment level 
p.ss_UNEM_BAR = 11.1;



%% === Typical and specific parameter values be used in calibrations === 
%-------- 1. Aggregate demand equation (the IS curve)
% L_GDP_GAP = b1*L_GDP_GAP{-1} - b2*MCI + b3*L_GDP_RW_GAP + b4*SHK_DLA_GDP_BAR - b5*SHK_L_GDP_BAR + SHK_L_GDP_GAP;
% MCI 		= b4*RR_GAP + (1-b4)*(- L_Z_GAP);

% output persistence;
p.b1 = 0.47; % b1 varies between 0.1 (extremely flexible) and 0.95(extremely persistent)
%0.47
% policy passthrough (the impact of monetary policy on real economy); 
p.b2 = 0.14; % b2 varies between 0.1 (low impact) to 0.5 (strong impact)
%0.14
% the impact of external demand on domestic output; 
p.b3 = 0.20; % b3 varies between 0.1 and 0.7
%0.20
% the weight of the real interest rate and real exchange rate gaps in Monetary Conditions Index;
p.b4 = 0.75; % b4 varies from 0.3 to 0.8 0.5
%0.75
%-------- 2. Inflation equation (the Phillips curve)
% DLA_CPI =  a1*DLA_CPI{-1} + (1-a1)*DLA_CPI{+1} + a2*RMC - a3*SHK_L_GDP_BAR + SHK_DLA_CPI;
% RMC 	  = a3*L_GDP_GAP + (1-a3)*L_Z_GAP;

% inflation persistence; 
% p.a1 = 0.3644; % a1 varies between 0.4 (low persistence) to 0.9 (high persistence)
p.a1 = 0.2912;
% passthrough of marginal costs to inflation (the impact of rmc on inflation); 
% p.a2 = 0.2383; % a2 varies between 0.1 (a flat Phillips curve and a high sacrifice ratio) to 0.5 (a steep Phillips curve and a low sacrifice ratio)
p.a2 = 0.2287;
% the ratio of domestic costs in firms' aggregate costs
% p.a3 = 0.6373; % a3 varies between 0.9 (for a relatively more closed economy) to 0.5 (for a relatively more open economy)
p.a3 = 0.7847;
%-------- 3. Monetary policy reaction function (a forward-looking Taylor rule)
% RS = g1*RS{-1} + (1-g1)*(RSNEUTRAL + g2*(D4L_CPI{+4} - D4L_CPI_TAR{+4}) + g3*L_GDP_GAP) + SHK_RS;

% policy persistence; 
p.g1 = 0.7; % g1 varies from 0 (no persistence) to 0.8 ("wait and see" policy)

% policy reactiveness: the weight put on inflation by the policy-makers 
p.g2 = 1.5; % g2 has no upper limit but must be always higher than 0 (the Taylor principle)

% policy reactiveness: the weight put on the output gap by the policy-makers 
p.g3 = 0.375; % g3 has no upper limit but must be always higher than 0

%-------- 4. Uncovered Interest Rate Parity (UIP)
% L_S = (1-e1)*L_S{+1} + e1*(L_S{-1} + 2/4*(D4L_CPI_TAR - ss_DLA_CPI_RW + DLA_Z_BAR)) + (- RS + RS_RW + PREM)/4 + SHK_L_S;

% the weight of the backward-looking component
p.e1 = 0.5; % setting e1 equal to 0 reduces the equation to the simple UIP 

%-------- 5. Speed of convergence of selected variables to their trend values.
% Used for inflation target, trends, and foreign variables 

% persistence of inflation target adjustment to the medium-term target (higher values mean slower adjustment)
% D4L_CPI_TAR = rho_D4L_CPI_TAR*D4L_CPI_TAR{-1} + (1-rho_D4L_CPI_TAR)*ss_D4L_CPI_TAR + SHK_D4L_CPI_TAR;
p.rho_D4L_CPI_TAR = 0.95; 

% persistence in convergence of trend variables to their steady-state levels
% applies for:   DLA_GDP_BAR, DLA_Z_BAR, RR_BAR and RR_RW_BAR
% example:
% DLA_Z_BAR = rho_DLA_Z_BAR*DLA_Z_BAR{-1} + (1-rho_DLA_Z_BAR)*ss_DLA_Z_BAR + SHK_DLA_Z_BAR;
p.rho_DLA_Z_BAR   = 0.5361;
p.rho_DLA_GDP_BAR = 0.7242;
p.rho_RR_BAR      = 0.9500;
p.rho_RR_RW_BAR   = 0.9500;

% persistence in foreign output gap 
% L_GDP_RW_GAP = rho_L_GDP_RW_GAP*L_GDP_RW_GAP{-1} + SHK_L_GDP_RW_GAP;
p.rho_L_GDP_RW_GAP = 0.7612;

% persistence in foreign interest rates and inflation
% RS_RW = rho_RS_RW*RS_RW{-1} + (1-rho_RS_RW)*(RR_BAR + DLA_CPI_RW) + SHK_RS_RW;
p.rho_RS_RW      = 0.9500;
p.rho_DLA_CPI_RW = 0.3131;

%% calibration components of unemployment
%L_GDP_BAR = L_GDP_BAR{-1} + DLA_GDP_BAR/4 - n1*4*(UNEM_BAR-UNEM_BAR{-1}) - (1-n1)*(UNEM_BAR{-1}-UNEM_BAR{-5}) + SHK_L_GDP_BAR;
p.n1    = 0.9;

%NAIRU
%UNEM_BAR = rho_UNEM_BAR*UNEM_BAR{-1} + (1-rho_UNEM_BAR)*ss_UNEM_BAR + DLA_UNEM_BAR - u1*(DLA_GDP_BAR{+8}+DLA_GDP_BAR{-16})/2 + SHK_UNEM_BAR;
p.rho_UNEM_BAR  = 0.2219; %0.3028
% p.u1            = [0 0.4434];
% p.u1            = 0.6594;
p.u1            = 0.3840;
%Unemployment growth rate
%DLA_UNEM_BAR = rho_DLA_UNEM_BAR*DLA_UNEM_BAR{-1} + SHK_DLA_UNEM_BAR;
p.rho_DLA_UNEM_BAR    = 0.8742;

%Unemployment gap
%UNEM_GAP = rho_UNEM_GAP*UNEM_GAP{-1} + u2*L_GDP_GAP + SHK_UNEM_GAP;
p.rho_UNEM_GAP  = 0.2521;
% p.u2            = 0.3973;
p.u2           = 0.4503;
%% == Standard deviations ===
p.std_SHK_L_GDP_GAP=4.0;
p.std_SHK_DLA_CPI= 1.2993; %1.3260
p.std_SHK_L_S= 10; %5.8057
p.std_SHK_RS= 2.35; %0.50
p.std_SHK_D4L_CPI_TAR= 2.85;
p.std_SHK_RR_BAR= 0.6308;
p.std_SHK_DLA_Z_BAR= 1.55;
%1.55
p.std_SHK_DLA_GDP_BAR= 0.5;
%0.5
p.std_SHK_L_GDP_RW_GAP= 4.20;
p.std_SHK_RS_RW= 0.3641;
p.std_SHK_DLA_CPI_RW= 3.1552;
p.std_SHK_RR_RW_BAR= 0.2;
p.std_SHK_UNEM_BAR= 0.8531; %0.7488
p.std_SHK_DLA_UNEM_BAR= 0.3119; %0.4882
p.std_SHK_UNEM_GAP= 0.1828; %0.3208 
p.std_SHK_L_GDP_BAR= 2.30;


%% === Solving the model === 
% 1) command 'model' reads the text file 'model.model' (contains the model's equations), 
% assigns the parameters and steady state values from database 'p' (see above),
% and transforms the model for the matrix algebra. Transformed model is written in the object 'm'. 
m = model('model_hyst.model','linear=',true,'assign',p);

% 2) command 'solve' takes the model object 'm' and solves the model
% for its reduced form (Blanchard-Kahn algorithm). The reduced form is again written in the object 'm'   
m = solve(m);

% 3) command 'sstate' further takes the model object 'm', calculates the model's
% steady-state and writes everything back in the object 'm'. 
m = sstate(m);


%% === Information which can be extracted from the model object === 
% a) extract steady-state values
mss = get(m,'sstate');

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