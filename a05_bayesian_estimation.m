%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Bayesian Estimation %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Housekeeping
clear; clc;
close all;

%% Read the model
[m,p,mss] = readmodel_est4();

%% Data sample
sdate = qq(2005,1);
edate = qq(2022,3);

%% Load data
d = dbload('results/history.csv');

dd.OBS_L_CPI        = d.L_CPI;
dd.OBS_L_GDP        = d.L_GDP;
dd.OBS_L_S          = d.L_S;
dd.OBS_RS           = d.RS;
dd.OBS_RS_RW        = d.RS_RW;
dd.OBS_DLA_CPI_RW   = d.DLA_CPI_RW;
dd.OBS_L_GDP_RW_GAP = d.L_GDP_RW_GAP;
dd.OBS_D4L_CPI_TAR  = d.D4L_CPI_TAR;
dd.OBS_UNEM			= d.UNEM;
dd.OBS_L_GDP_GAP	= d.L_GDP_GAP;
dd.OBS_L_GDP_GAP(qq(2011,2))  = 0.0;
dd.OBS_L_GDP_GAP(qq(2013,2))  = 0.0;
dd.OBS_L_GDP_GAP(qq(2019,3))  = 0.1;
dd.OBS_L_GDP_GAP(qq(2021,4))  = 2.0;

%% Set priors
e = struct();
% % Potential output
e.n1 = {NaN,0,1,logdist.beta(0.7,0.210)};
% % Unemployment
e.u1 = {NaN,0.01,0.99,logdist.beta(0.45,0.180)};
e.u2 = {NaN,0.01,0.99,logdist.beta(0.521,0.156)};
% % Persistances
e.rho_UNEM_BAR		= {NaN,0.01,0.99,logdist.beta(0.120,0.036)};
e.rho_DLA_UNEM_BAR	= {NaN,0.01,0.99,logdist.beta(0.880,0.004)};
e.rho_UNEM_GAP		= {NaN,0.01,0.99,logdist.beta(0.407,0.122)};
% % Standard deviations
e.std_SHK_UNEM_BAR	   = {NaN,0.001,10,logdist.invgamma(0.0249,0.0012)};
e.std_SHK_DLA_UNEM_BAR = {NaN,0.001,10,logdist.invgamma(0.0248,0.0012)};
e.std_SHK_UNEM_GAP	   = {NaN,0.001,10,logdist.invgamma(0.4976,0.0249)};

%% Bayesian estimation
% [p_est,post,cov,hess,m_est,v,delta,p_delta] = estimate(m,dd,sdate:edate,e);
[p_est,~,cov,~,m_est,~,~,~] = estimate(m,dd,sdate:edate,e, ...
									   'maxIter',100000, ...
									   'maxFunEvals',100000);

% par = get(m_est,'params');

% save params_est par






