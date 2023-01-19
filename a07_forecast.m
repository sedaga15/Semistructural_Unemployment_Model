%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Forecast %%%
%%%%%%%%%%%%%%%%%%%%%%%%%

%% Housekeeping
clear; clc;
close all;

%% Read the model
[m,p,mss] = readmodel_est();

%% Load data
load('results/kalm_his.mat');
h = g;
clear g

%% Define the time frame of the forecast
% Change the time frame depending on you data and forecast period!
startfcast = get(h.mean.L_GDP_GAP, 'last') + 1;
endfcast   = startfcast + 8;
fcastrange = startfcast:endfcast;

simplan = plan(m, fcastrange);

%% Forecast
f = jforecast(m,h,fcastrange, 'plan', simplan, 'anticipate', true);

f.mean = dbextend(h.mean, f.mean);
f.std = dbextend(h.std, f.std);

%% Graphs
vars = {
	'L_GDP_GAP'		'Brecha del producto'
	'UNEM_BAR'		'NAIRU'
	'L_GDP_BAR'		'Producto potencial'
	'RS'			'Tasa de política monetaria'
};

set(0,'DefaultFigureWindowState','maximized')
set(0,'DefaultAxesFontName','Times New Roman')
set(0,'DefaultAxesFontSize',14)

figure('Name','Baseline Forecast','Color','w','NumberTitle','off')
for ii = 1:size(vars,1)
	subplot(2,2,ii)
	p = plot(f.mean.(vars{ii,1}), ...
		'LineWidth',3,'Color',[204,51,17]/255);
	hold on
% 	grid on
	v = vline(startfcast);
	v.LineStyle = '-';	v.Color = [0,0,0]/255; v.LineWidth = 1.5;
	highlight(1.0e+03*2.0224:1.0e+03*2.02338,'color',[187 204 238]/255);
	highlight(1.0e+03*2.02338:1.0e+03*2.0249,'color',[204 221 170]/255);
	title(vars{ii,2})
	xlabel('Periodo')
	if ii ~= 3
		ylabel('%')
	end
	datxtick(qq(2022,2):qq(2024,4))
end
set(gcf,'renderer','Painters')
print -depsc -tiff -r300 -painters seccion3\forecast.eps
% saveas(gcf,'seccion3\forecast.eps','epsc')

set(0,'DefaultFigureWindowState','maximized')
set(0,'DefaultAxesFontName','default')
set(0,'DefaultAxesFontSize','default')
