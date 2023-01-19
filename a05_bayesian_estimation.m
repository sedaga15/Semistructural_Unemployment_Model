%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Bayesian Estimation %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Housekeeping
clear; clc;
close all;

%% Read the model
[m,p,mss] = readmodel();

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
% % IS parameters
e.b1 = {NaN,0.1,0.9,logdist.beta(0.5,0.1)};
e.b2 = {NaN,0.1,0.5,logdist.beta(0.3,0.1)};
e.b3 = {NaN,0.1,0.7,logdist.beta(0.2,0.1)};
e.b4 = {NaN,0.3,0.8,logdist.beta(0.5,0.1)};
% % Phillips curve
e.a1 = {NaN,0.2,0.9,logdist.beta(0.5,0.1)};
e.a2 = {NaN,0.1,0.5,logdist.beta(0.3,0.1)};
e.a3 = {NaN,0.5,0.9,logdist.beta(0.6,0.1)};
% % Monetary policy
% e.g1 = {NaN,0.0,0.8,logdist.beta(0.5,0.1)};
% e.g2 = {NaN,0.0,2.0,logdist.normal(1.5,0.3)};
% e.g3 = {NaN,0.0,1.0,logdist.beta(0.3,0.1)};
% % UIP
% e.e1 = {NaN,0.0,0.5,logdist.beta(0.3,0.1)};
% % Potential output
e.n1 = {NaN,0.1,0.9,logdist.beta(0.7,0.2)};
% % Unemployment
e.u1 = {NaN,0.1,0.8,logdist.beta(0.45,0.2)};
e.u2 = {NaN,0.2,0.7,logdist.beta(0.5,0.1)};
% % Persistances
e.rho_D4L_CPI_TAR	= {NaN,0.05,0.95,logdist.beta(0.7,0.2)};
e.rho_DLA_Z_BAR		= {NaN,0.05,0.95,logdist.beta(0.7,0.2)};
e.rho_RR_BAR		= {NaN,0.05,0.95,logdist.beta(0.7,0.2)};
e.rho_DLA_GDP_BAR	= {NaN,0.05,0.95,logdist.beta(0.7,0.2)};
e.rho_L_GDP_RW_GAP	= {NaN,0.05,0.95,logdist.beta(0.7,0.2)};
e.rho_RS_RW			= {NaN,0.05,0.95,logdist.beta(0.7,0.2)};
e.rho_DLA_CPI_RW	= {NaN,0.05,0.95,logdist.beta(0.7,0.2)};
e.rho_RR_RW_BAR		= {NaN,0.05,0.95,logdist.beta(0.7,0.2)};
e.rho_UNEM_BAR		= {NaN,0.05,0.95,logdist.beta(0.7,0.2)};
e.rho_DLA_UNEM_BAR	= {NaN,0.05,0.95,logdist.beta(0.7,0.2)};
e.rho_UNEM_GAP		= {NaN,0.05,0.95,logdist.beta(0.7,0.2)};
% % Standard deviations
e.std_SHK_L_GDP_GAP    = {NaN,0.001,5,logdist.invgamma(0.1,0.1)};
e.std_SHK_DLA_CPI      = {NaN,0.001,5,logdist.invgamma(0.1,0.1)};
e.std_SHK_L_S		   = {NaN,0.001,5,logdist.invgamma(0.1,0.1)};
e.std_SHK_RS		   = {NaN,0.001,5,logdist.invgamma(0.1,0.1)};
e.std_SHK_D4L_CPI_TAR  = {NaN,0.001,5,logdist.invgamma(0.1,0.1)};
e.std_SHK_RR_BAR       = {NaN,0.001,5,logdist.invgamma(0.1,0.1)};
e.std_SHK_DLA_Z_BAR	   = {NaN,0.001,5,logdist.invgamma(0.1,0.1)};
e.std_SHK_DLA_GDP_BAR  = {NaN,0.001,5,logdist.invgamma(0.1,0.1)};
e.std_SHK_L_GDP_RW_GAP = {NaN,0.001,5,logdist.invgamma(0.1,0.1)};
e.std_SHK_RS_RW        = {NaN,0.001,5,logdist.invgamma(0.1,0.1)};
e.std_SHK_DLA_CPI_RW   = {NaN,0.001,5,logdist.invgamma(0.1,0.1)};
e.std_SHK_RR_RW_BAR    = {NaN,0.001,5,logdist.invgamma(0.1,0.1)};
e.std_SHK_UNEM_BAR	   = {NaN,0.001,5,logdist.invgamma(0.1,0.1)};
e.std_SHK_DLA_UNEM_BAR = {NaN,0.001,5,logdist.invgamma(0.1,0.1)};
e.std_SHK_UNEM_GAP	   = {NaN,0.001,5,logdist.invgamma(0.1,0.1)};
e.std_SHK_L_GDP_BAR	   = {NaN,0.001,5,logdist.invgamma(0.1,0.1)};

%% Bayesian estimation
% [p_est,post,cov,hess,m_est,v,delta,p_delta] = estimate(m,dd,sdate:edate,e);
[p_est,post,cov,~,m_est,~,~,~] = estimate(m,dd,sdate:edate,e);







