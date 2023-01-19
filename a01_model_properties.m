%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Impulse Response Functions %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Housekeeping
clear; clc;
close all;

%% If non-existent, create "results" folder where all results will be stored
[~,~,~] = mkdir('results');

%% Read the model
[m,p,mss] = readmodel();

%% Define shocks
% One period unexpected shocks: inflation, output, exchange rate, interest rate
% Create a list of shock variables and a list of their titles. The shock variables
% must have the names found in the model code (in file 'model.model')
% listshocks = {'SHK_L_GDP_GAP','SHK_DLA_CPI','SHK_RS','SHK_UNEM_BAR', 'SHK_L_GDP_BAR'};
% listtitles = {'Output Gap Shock','Cost push Shock', 'Interest rate Shock', 'Unemployment Shock', 'Output trend Shock'};
listshocks = {'SHK_L_GDP_GAP'};
listtitles = {'Output Gap Shock'};

% Set the time frame for the simulation 
startsim = qq(0,1);
endsim = qq(5,1);

% For each shock a zero database is created (command 'zerodb') and named as 
% database 'd.{shock_name}'
for i = 1:length(listshocks)
    d.(listshocks{i}) = zerodb(m,startsim:endsim);
end

% Fill the respective databases with the shock values for the starting
% point of the simulation (startsim). For simplicity, all shocks are set to
% 1 percent
d.SHK_L_GDP_GAP.SHK_L_GDP_GAP(startsim) = -1;
% d.SHK_DLA_CPI.SHK_DLA_CPI(startsim) = 1;
% d.SHK_RS.SHK_RS(startsim) = 1;
% d.SHK_UNEM_BAR.SHK_UNEM_BAR(startsim) = 1; 
% d.SHK_L_GDP_BAR.SHK_L_GDP_BAR(startsim) = 1;
%% Simulate IRFs
% Simulate the model's response to a given shock using the command 'simulate'.
% The inputs are model 'm' and the respective database 'd.{shock_name}'.
% Results are written in database 's.{shock_name}'.
for i=1:length(listshocks)    
    s.(listshocks{i}) = simulate(m,d.(listshocks{i}),startsim:endsim,'deviation',true);
end

%% Generate pdf report
x = Report.new('Shocks');

% Figure style
sty = struct();
sty.line.linewidth = 1;
sty.line.linestyle = {'-';'--'};
sty.line.color = {'k';'r'};
sty.legend.location = 'Best';

% Create separate page with IRFs for each shock
for i = 1:length(listshocks)

x.figure(listtitles{i},'zeroline',true,'style',sty, ...
         'range',startsim:endsim,'legend',false,'marks',{'Hysteresis','No Hysteresis'});

GraphOptions = {'xLabel=','Quarters','yLabel=','% dev. from ss'};

x.graph('Unemployment rate',GraphOptions{:},'legend',true);
x.series('', s.(listshocks{i}).UNEM);

x.graph('CPI Inflation QoQ (% ar)',GraphOptions{:});
x.series('',s.(listshocks{i}).DLA_CPI);

x.graph('GDP Trend',GraphOptions{:});
x.series('', s.(listshocks{i}).L_GDP_BAR);

x.graph('GDP Trend Growth',GraphOptions{:});
x.series('', s.(listshocks{i}).GROWTH_BAR);

x.graph('Unemployment Trend',GraphOptions{:});
x.series('', s.(listshocks{i}).UNEM_BAR);

x.graph('Output Gap (%)',GraphOptions{:});
x.series('',[s.(listshocks{i}).L_GDP_GAP]);

x.graph('Nominal Interest Rate (% ar)',GraphOptions{:});
x.series('',s.(listshocks{i}).RS);





% x.graph('Unemployment Gap',GraphOptions{:});
% x.series('', s.(listshocks{i}).UNEM_GAP);



x.graph('Real Interest Rate Gap (%)',GraphOptions{:});
x.series('', s.(listshocks{i}).RR_GAP);

x.graph('Real Exchange Rate Gap (%)',GraphOptions{:});
x.series('', s.(listshocks{i}).L_Z_GAP);

% x.graph('Real Interest Rate (%)',GraphOptions{:});
% x.series('', s.(listshocks{i}).RR);

% x.graph('Nominal ER Deprec. QoQ (% ar)',GraphOptions{:});
% x.series('',s.(listshocks{i}).DLA_S);


end

x.publish('results/Shocks.pdf','display',false);
disp('Done!!!');