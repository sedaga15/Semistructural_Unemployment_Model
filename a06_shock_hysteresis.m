%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Impulse Response Functions %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Housekeeping
clear; clc;
close all;

%% Read the model
[m,p,mss] = readmodel_est(); % Change u1 parameter with 0

%% Define shocks
listshocks = {'SHK_L_GDP_GAP'};
listtitles = {'Choque negativo de demanda'};

% Set the time frame for the simulation 
startsim = qq(2020,1);
endsim = qq(2024,4);

% For each shock a zero database is created (command 'zerodb') and named as 
% database 'd.{shock_name}'
for i = 1:length(listshocks)
    d.(listshocks{i}) = zerodb(m,startsim:endsim);
end

% Fill the respective databases with the shock values for the starting
% point of the simulation (startsim). For simplicity, all shocks are set to
% 1 percent
d.SHK_L_GDP_GAP.SHK_L_GDP_GAP(startsim) = -1;

%% Simulate IRFs
% Simulate the model's response to a given shock using the command 'simulate'.
% The inputs are model 'm' and the respective database 'd.{shock_name}'.
% Results are written in database 's.{shock_name}'.
for i=1:length(listshocks)    
    s.(listshocks{i}) = simulate(m,d.(listshocks{i}),startsim:endsim,'deviation',true);
end

%% Graphs

% Demand Shock
vars = {
	'UNEM'				'Desempleo'
	'DLA_CPI'			'Inflación'
	'L_GDP_BAR'			'Producto Potencial'
	'UNEM_GAP'			'Brecha de desempleo'
	'UNEM_BAR'			'NAIRU'
	'L_GDP_GAP'			'Brecha del producto'
};

% setting custom colors
colors = [
	31,120,180
	152,78,163
	1,1,1
	51,160,44
	251,154,153
	227,26,28
	53,151,143
	254,224,139
	255,127,0
	202,178,214
]/255;

leg_ = {'No histéresis' 'Histéresis'};

% Common setup
set(0,'DefaultAxesColorOrder',colors)
set(0,'DefaultAxesFontName','Times New Roman')
set(0,'DefaultAxesFontSize',14)
set(0,'DefaultFigureWindowState','maximized')

figure('Name','Negative Demand Shock','Color','w','NumberTitle','off');
for ii = 1:length(vars)
	subplot(2,3,ii)
	plot(s.SHK_L_GDP_GAP.(vars{ii,1}),'LineWidth',3)
	hold on
	yline(0,'LineWidth',1.5,'LineStyle','--')
	grid on
	grid minor
	title(vars{ii,2})
	ylabel('Desviación (%)')
	datxtick(startsim:endsim)
end
legend(leg_,'Position',[0.515 0.03 0 0],'Orientation','horizontal')
saveas(gcf,'seccion3\dem_hist.eps','epsc')

%% Revert to default
set(0,'DefaultAxesColorOrder','default')
set(0,'DefaultAxesFontName','default')
set(0,'DefaultAxesFontSize','default')
set(0,'DefaultFigureWindowState','normal')