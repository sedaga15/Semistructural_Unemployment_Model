%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Preparation of the database %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Housekeeping
clear; clc;
close all;

addpath utils

%% If non-existent, create "results" folder where all results will be stored
[~,~,~] = mkdir('results');

%% Load quarterly data
% Command 'dbdload' loads the data from the 'csv' file (save from Excel as
% .csv in the current directory). All the data are now available in the
% database 'd' 
d = dbload('data.csv');

%% Seasonal adjustment
% Seasonally adjust all time series whose names end with _U, and give these 
% seasonally adjusted series names without the _U.
d = dbbatch(d,'$1','x12(d.$0,Inf,''mode'',''m'')','namefilter','(.*)_U','fresh',false);
 
%% Make log of variables

exceptions = {'RS','RS_RW','D4L_CPI_TAR','UNEM'};

d = dbbatch(d,'L_$0','100*log(d.$0)','namelist',fieldnames(d)-exceptions,'fresh',false);

%% Define the real exchange rate
d.L_Z = d.L_S + d.L_CPI_RW - d.L_CPI;

%% Growth rate qoq, yoy
d = dbbatch(d,'DLA_$1','4*diff(d.$0)','namefilter','L_(.*)','fresh',false);
d = dbbatch(d,'D4L_$1','diff(d.$0,-4)','namefilter','L_(.*)','fresh',false);

%% Real variables
% Domestic real interest rate
d.RR = d.RS - d.D4L_CPI;

% Foreign real interest rate
d.RR_RW = d.RS_RW - d.D4L_CPI_RW;

%% Trends and Gaps - Hodrick-Prescott filter
list = {'RR','L_Z','RR_RW'};
for i = 1:length(list)
    [d.([list{i} '_BAR']), d.([list{i} '_GAP'])] = hpf(d.(list{i}));
end

d.DLA_Z_BAR = 4*diff(d.L_Z_BAR);

%% Trend and Gap for Output - Band-pass filter
d.L_GDP_GAP = bpass(d.L_GDP,[6,32],inf);
d.L_GDP_BAR = bpass(d.L_GDP,[32,Inf],inf);
d.DLA_GDP_BAR = 4*(d.L_GDP_BAR - d.L_GDP_BAR{-1});

%% Foreign Output gap - HP filter with judgements

[d.L_GDP_RW_BAR_PURE, d.L_GDP_RW_GAP_PURE] = hpf(d.L_GDP_RW,inf,'lambda',1600);
[d.L_GDP_RW_BAR, d.L_GDP_RW_GAP] = hpf(d.L_GDP_RW,inf,'lambda',1600);
% Expert judgement on the foreign output gap
% JUDGEMENT = tseries(qq(2019,1):qq(2020,4),[0.9 3.0 1.8 -2.0 -7.4 -2.1 -2.3 -2.7 -3 -3.2 -3.4 -3.6]);
% [d.L_GDP_RW_BAR, d.L_GDP_RW_GAP] = hpf(d.L_GDP_RW,inf,'lambda',1600,'level',d.L_GDP_RW-JUDGEMENT);


%% Save the database
% Database is saved in file 'history.csv'
dbsave(d,'results/history.csv');

%% Report - Stylized Facts
disp('Generating Stylized Facts Report...');
x = Report.new('Stylized Facts report');

% Figures
rng = get(d.D4L_CPI,'range');

sty = struct();
sty.line.linewidth = 0.5;
sty.line.linestyle = {'-';'--'};
sty.line.color = {'k';'k'};
sty.legend.orientation = 'horizontal';
sty.axes.box = 'on';

x.figure('Nominal Variables','subplot',[2,3],'style',sty,'range',rng,...
  'dateformat','YYFP',...
  'legendLocation','SouthOutside');

x.graph('Headline Inflation (%)','legend',true);
x.series('',[d.DLA_CPI d.D4L_CPI],'legendEntry=',{'q-o-q','y-o-y'});

x.graph('Foreign Inflation (%)','legend',true);
x.series('',[d.DLA_CPI_RW d.D4L_CPI_RW],'legendEntry=',{'q-o-q','y-o-y'});

x.graph('Nominal Exchange Rate: LCY per 1 FCY','legend',false);
x.series('',[d.S]);

x.graph('Nominal Exchange Rate (%)','legend',true);
x.series('',[d.DLA_S d.D4L_S],'legendEntry=',{'q-o-q','y-o-y'});

x.graph('Nom. Interest Rate (% p.a.)','legend',false);
x.series('',[d.RS]);

x.graph('Foreign Nom. Interest Rate (% p.a.)','legend',false);
x.series('',[d.RS_RW]);

x.pagebreak();

% New figure
x.figure('Real Variables','subplot',[2,3],'style',sty,'range',rng,...
  'dateformat','YYFP','legendLocation','SouthOutside');

x.graph('GDP Growth (%)','legend',true);
x.series('',[d.DLA_GDP d.D4L_GDP],'legendEntry=',{'q-o-q','y-o-y'});

x.graph('GDP (100*log)','legend',true,'legendLocation','bottom');
x.series('',[d.L_GDP d.L_GDP_BAR],'legendEntry=',{'level','trend'});

x.graph('Real Interest Rate (% p.a.)','legend',false);
x.series('',[d.RR d.RR_BAR],'legendEntry=',{'level','trend'});

x.graph('Real Exchange Rate (100*log)','legend',false);
x.series('',[d.L_Z d.L_Z_BAR],'legendEntry=',{'level','trend'});

x.graph('Foreign GDP (100*log)','legend',false);
x.series('',[d.L_GDP_RW d.L_GDP_RW_BAR],'legendEntry=',{'level','trend'});

x.graph('Foreign Real Interest Rate (% p.a.)','legend',false);
x.series('',[d.RR_RW d.RR_RW_BAR],'legendEntry=',{'level','trend'});

x.pagebreak();

x.figure('Gaps','subplot',[3,2],'style',sty,'range',rng,'dateformat','YYFP');

x.graph('GDP Gap (%)','legend',false);
x.series('',[d.L_GDP_GAP]);

x.graph('Foreign GDP Gap (%)','legend',false);
x.series('',[d.L_GDP_RW_GAP]);

x.graph('Real Interest Rate Gap (p.p. p.a.)','legend',false);
x.series('',[d.RR_GAP]);

 x.graph('Unemployment rate','legend',false);
 x.series('',[d.UNEM]);

x.publish('results/Stylized_facts','display',false);

disp('Done!!!');

rmpath utils