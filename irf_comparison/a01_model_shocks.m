%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Impulse Response Functions %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% NOTE: Only works with one shock

%% Housekeeping
clear; clc;
close all;

%% Read the model
[m_nh,p_nh,mss_nh] = readmodel_nohyst();
[m_h,p_h,mss_h] = readmodel_hyst();

%% Define shocks
% Simulation range
s_sim = yy(0);
e_sim = yy(20);

% Create shock database (hysteresis)
d_h = zerodb(m_h,s_sim:e_sim);

% Assign the shock value
d_h.SHK_L_GDP_GAP(s_sim) = -1;

%% Simulate IRF for hysteresis scenario
s_h = simulate(m_h,d_h,s_sim:e_sim,'deviation',true,'anticipate',false);

%% Endogenize shock - exogenize unemployment for no-hysteresis
% Simulation plan
sim_plan = plan(m_nh,s_sim:e_sim);

% Shock database
d_nh = zerodb(m_nh,s_sim:e_sim);

% Assign unemployment path from hysteresis simulation
d_nh.UNEM = s_h.UNEM;
sim_plan = exogenize(sim_plan,s_sim:e_sim,'UNEM');
sim_plan = endogenize(sim_plan,s_sim:e_sim,'SHK_L_GDP_GAP');

%% Simulate IRF for no-hysteresis scenario
s_nh = simulate(m_nh,d_nh,s_sim:e_sim,'deviation',true,'plan',sim_plan,'anticipate',false);

%% Graphs
% Demand Shock
vars = {
	'UNEM'					'Desempleo'
	'DLA_CPI'				'Inflación'
	'L_GDP_BAR'				'Producto Potencial'
	'GROWTH_BAR'			'Crecimiento potencial'
% 	'UNEM_GAP'				'Brecha de desempleo'
	'UNEM_BAR'				'NAIRU'
	'L_GDP_GAP'				'Brecha del producto'
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

leg_ = {'Histéresis' 'No Histéresis'};

% Common setup
set(0,'DefaultAxesColorOrder',colors)
set(0,'DefaultAxesFontName','Times New Roman')
set(0,'DefaultAxesFontSize',14)
set(0,'DefaultFigureWindowState','maximized')

figure('Name','Negative Demand Shock','Color','w','NumberTitle','off');
for ii = 1:length(vars)
	subplot(2,3,ii)
	hold on
	plot(s_h.(vars{ii,1}),'LineWidth',2)
	plot(s_nh.(vars{ii,1}),'LineWidth',2)
	yline(0,'LineWidth',1.5,'LineStyle','--','Color','k')
	grid on
	grid minor
	title(vars{ii,2})
	ylabel('Desviación (%)')
	datxtick(s_sim:e_sim)
end
legend(leg_,'Position',[0.515 0.03 0 0],'Orientation','horizontal')

disp('Done!!')

%% Revert to default
set(0,'DefaultAxesColorOrder','default')
set(0,'DefaultAxesFontName','default')
set(0,'DefaultAxesFontSize','default')
set(0,'DefaultFigureWindowState','normal')