%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Kalman filtration %%%
%%%%%%%%%%%%%%%%%%%%%%%%%

%% Housekeeping
clear; clc;
close all;

addpath utils

%% Read the model
[m,p,mss] = readmodel_est();

%% Create model report 
m = modelreport(m);

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

%% Filtration
% Input arguments:
%   m - solved model object
%   dd - database with observations for measurement variables
%   sdate:edate - date range to tun the filter
% Some output arguments:
%   m_kf - model object
%   g - output structure with smoother or prediction data
%   v - estimated variance scale factor
[m_kf,g,v,delta,pe] = filter(m,dd,sdate:edate,'returnCont=',true);

h = g.mean;
d = dbextend(d,h);

%% Save the database
% Database is saved in file 'kalm_his.mat'
dbsave(d,'results/kalm_his.csv');
save('results/kalm_his.mat', 'g');

%% Report 
% full version
disp('Generating Filtration Report...');
x = report.new('Filtration report','visible',true);

%% Figures
% rng = qq(2012,1):edate;
rng = sdate:edate;
sty = struct();
sty.line.linewidth = 0.5;
sty.title.fontsize = 6;
sty.axes.fontsize = 6;
sty.line.linestyle = {'-';'--'};
sty.line.color = {'k';'r'};
sty.axes.box = 'off';
sty.legend.location='Best';
sty.legend.FontSize=3;

x.figure('Observed and Trends','subplot',[2,3],'style',sty,'range',rng,'dateformat','YY:P');

x.graph('GDP','legend',false);
x.series('',[d.L_GDP d.L_GDP_BAR]);

x.graph('Real Interest Rate','legend',false);
x.series('',[d.RR d.RR_BAR]);

x.graph('Foreign Real Interest Rate','legend',false);
x.series('',[d.RR_RW d.RR_RW_BAR]);

x.graph('Real Exchange Rate','legend',false);
x.series('',[d.L_Z d.L_Z_BAR]);

x.graph('Change in Eq. Real Exchange rate','legend',false);
x.series('',[d.DLA_Z_BAR]);

x.graph('Risk Premium','legend',false);
x.series('',[d.PREM]);

x.pagebreak();

x.figure('Gaps','subplot',[3,3],'style',sty,'range',rng,'dateformat','YY:P');

x.graph('Inflation','legend',false);
x.series('',[d.DLA_CPI d.D4L_CPI_TAR]);

x.graph('Marginal Cost','legend',false);
x.series('',[d.RMC]);

x.graph('GDP GAP','legend',false);
x.series('',[d.L_GDP_GAP]);

x.graph('Monetary Conditions','legend',false);
x.series('',[d.MCI]);

x.graph('Real Interest Rate Gap','legend',false);
x.series('',[d.RR_GAP]);

x.graph('Real Exchange Rate Gap','legend',false);
x.series('',[d.L_Z_GAP]);

x.graph('Foreign GDP Gap','legend',false);
x.series('',[d.L_GDP_RW_GAP]);

x.graph('Foreign inflation','legend',false); % to be added during the video
x.series('',[d.DLA_CPI_RW]); % to be added during the video

x.graph('Foreign interest rates','legend',false); % to be added during the video
x.series('',[d.RS_RW]); % to be added during the video

x.figure('Shocks','subplot',[3,3],'style',sty,'range',rng,'dateformat','YY:P');

x.graph('Inflation (cost-push)','legend',false);
x.series('',[d.SHK_DLA_CPI]);

x.graph('Output gap','legend',false);
x.series('',[d.SHK_L_GDP_GAP]);

x.graph('Interest Rate','legend',false);
x.series('',[d.SHK_RS]);

x.graph('Exchange Rate','legend',false);
x.series('',[d.SHK_L_S]);

x.graph('Trend Real Interest Rate','legend',false);
x.series('',[d.SHK_RR_BAR]);

x.graph('Trend Real Exchange Rate','legend',false);
x.series('',[d.SHK_DLA_Z_BAR]);

x.figure('Interest rate and exchange rate','subplot',[3,3],'style',sty,'range',rng,'dateformat','YY:P');

x.graph('Nominal interest rate','legend',false);
x.series('',[d.RS]);

x.graph('Real Interest Rate Gap','legend',false);
x.series('',[d.RR_GAP]);

x.graph('Inflation qoq','legend',false);
x.series('',[d.DLA_CPI]);

x.graph('Nominal exchange rate rate','legend',false);
x.series('',[d.S]);

x.graph('Real Exchange Rate Gap','legend',false);
x.series('',[d.L_Z_GAP]);

x.graph('Nominal exchange rate rate depreciation','legend',true);
x.series('',[d.DLA_S d.D4L_S], 'legendEntry=',{'qoq','yoy'});

x.graph('Inflation differential','legend',true);
x.series('',[d.DLA_CPI d.DLA_CPI_RW], 'legendEntry=', {'domestic inflation','foreign inflation'});

x.graph('Interest rate differential','legend',true);
x.series('',[d.RS d.RS_RW], 'legendEntry=', {'domestic IR','foreign IR'});

x.graph('Exchange rate shock','legend',false);
x.series('',[d.SHK_L_S]);

x.figure('Inflation','subplot',[3,1],'style',sty,'range',rng,'dateformat','YY:P');

x.graph('Inflation qoq, percent','legend',true);
x.series('',[d.DLA_CPI d.DLA_CPI-d.SHK_DLA_CPI], 'legendEntry=', {'Actual','Predicted'});

x.graph('Inflation and RMC, percent','legend',true);
x.series('',[d.DLA_CPI-d.D4L_CPI_TAR d.RMC],'legendEntry=', {'Inflation (deviation from the target)','RMC'});

x.graph('Marginal cost decomposition, pp','legend',true);
x.series('',[d.a3*d.L_GDP_GAP (1-d.a3)*d.L_Z_GAP],'legendEntry=',{'Output gap','RER gap'},'plotfunc',@barcon);
x.series('',d.RMC,'legendEntry=',{'RMC'});

x.figure('','style',sty,'range',rng,'dateformat','YY:P');
x.graph('Inflation decomposition, qoq percent','legend',true);
x.series('',[d.a1*d.DLA_CPI{-1} (1-d.a1)*d.E_DLA_CPI d.a2*d.a3*d.L_GDP_GAP d.a2*(1-d.a3)*d.L_Z_GAP d.SHK_DLA_CPI],...
  'legendEntry=',{'Persistency','Expectations','Output Gap','RER Gap','Shock'},'plotfunc',@barcon);
x.series('',d.DLA_CPI,'legendEntry=',{'Inflation'});

x.figure('Output gap','subplot',[2,1],'style',sty,'range',rng,'dateformat','YY:P');

x.graph('Output gap, percent','legend',true);
x.series('',[d.L_GDP_GAP d.L_GDP_GAP-d.SHK_L_GDP_GAP],'legendEntry=',{'Actual','Predicted'});

x.graph('Output gap decomposition, pp','legend',true);
x.series('',[d.b1*d.L_GDP_GAP{-1} -d.b2*d.b4*d.RR_GAP d.b2*(1-d.b4)*d.L_Z_GAP d.b3*d.L_GDP_RW_GAP d.SHK_L_GDP_GAP],...
    'legendEntry=',{'Lag','RIR gap','RER gap','Foreign gap','Shock'},'plotfunc',@barcon);

x.figure('Decomposition','subplot',[2,1],'style',sty,'range',rng,'dateformat','YY:P');

x.graph('MCI decomposition, pp','legend',true);
x.series('',[d.b4*d.RR_GAP (1-d.b4)*(-d.L_Z_GAP)],'legendEntry=',{'RIR gap','RER gap'},'plotfunc',@barcon);
x.series('',d.MCI,'legendEntry=','MCI');

x.pagebreak();

x.figure('Decomposition','style',sty,'range',rng,'dateformat','YY:P');
x.graph('NAIRU','legend',true);
x.series('',[d.rho_UNEM_BAR*d.UNEM_BAR{-1} (1-d.rho_UNEM_BAR)*d.ss_UNEM_BAR d.DLA_UNEM_BAR d.u1*d.L_GDP_GAP d.SHK_UNEM_BAR], ...
	'legendEntry=',{'Lag','Steady State','Growth','GDP gap','Shock'},'plotfunc',@barcon);

x.publish('results/Filtration','display',false);
disp('Done!!!');

rmpath utils