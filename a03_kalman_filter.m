%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Kalman filtration %%%
%%%%%%%%%%%%%%%%%%%%%%%%%

%% Housekeeping
clear; clc;
close all;

addpath utils

REPORT = false;

%% Read the model
[m,p,mss] = readmodel_est();

%% Set standard deviations
p.std_SHK_L_GDP_GAP= 1.0582;
p.std_SHK_DLA_CPI= 1.4679;
p.std_SHK_L_S= 1.5966;
p.std_SHK_RS= 0.13667;
p.std_SHK_D4L_CPI_TAR= 0.29516;
p.std_SHK_RR_BAR= 1.2961;
p.std_SHK_DLA_Z_BAR= 11.537;
p.std_SHK_DLA_GDP_BAR= 0.37678;
p.std_SHK_L_GDP_RW_GAP= 0.4366;
p.std_SHK_RS_RW= 0.1153;
p.std_SHK_DLA_CPI_RW= 0.9828;
p.std_SHK_RR_RW_BAR= 0.5563;
p.std_SHK_UNEM_BAR= 1.0329;
p.std_SHK_DLA_UNEM_BAR= 0.48086;
p.std_SHK_UNEM_GAP= 0.12812;
p.std_SHK_L_GDP_BAR= 1.6647;

m = assign(m,p);
m = solve(m);

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

%% Setup the filtration
stds = get(m,'std');         % get the names of all model shock stds 
list_std = fieldnames(stds); % convert those into a cell array
% now for each std create a time series with the value of 1 repeated
% for every period
mult = dbbatch(stds,'$0','Series(sdate:edate,1)','namelist',list_std);

list_std = fieldnames(get(m,'std'));
rw_std = {'std_SHK_L_GDP_RW_GAP','std_SHK_RS_RW','std_SHK_DLA_CPI_RW','std_SHK_RR_RW_BAR'};
list_std = setdiff(list_std,rw_std);

%--- a database of updated (i.e. multiplied) STDs
p_aux = (get(m,'param'));
dbstd = dbbatch(mult,'$0','mult.$0.*p_aux.$0','namelist',list_std);

[mod_ev,p_ev,tmp,a,b,multvcov] = find_shock_mult(0.10,10,1e-3,30,p,m,dd,...
                                               sdate:edate,list_std,dbstd);

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

%%

m_kf = mod_ev;
enames = list_std';

sc0        = [];
se0        = [];
log_contr0 = [];
for iter = 1:numel(enames)
  ename           = enames{iter}(5:end);
  sc0(iter)        = m_kf.(['std_' ename]);
  se0(iter)        = std(d.(ename)(sdate:edate));
  
  aux             = sc0(iter)*mult.(['std_' ename]);
  log_contr0(iter) = sum((d.(ename)(sdate:edate)./(aux(sdate:edate))).^2);  
end

t0 = table(log_contr0',sc0', se0', ...
          'VariableNames', {'Loglik','Calibr','Estim'}, ...
          'RowNames', enames');
disp(t0);

%% Report 
if REPORT
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

end

rmpath utils