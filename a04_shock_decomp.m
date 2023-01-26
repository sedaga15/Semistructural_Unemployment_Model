%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Historical shock decomposition %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Housekeeping
clear; 
% clc;
close all;

%% Read the model
[m,p,mss] = readmodel_est4();

%% Load filtered data
d = dbload('results\kalm_his.csv');

%% Data sample
sdate = qq(2005,1);
edate = qq(2022,3);
drange = sdate:edate;

%% Simulate data and compile decomposition
s = simulate(m,d,drange,'anticipate',false,'contributions',true);

%% Group shocks
g = grouping(m,'shocks');

g = addgroup(g,'Demanda','SHK_L_GDP_GAP');
g = addgroup(g,'Oferta',{'SHK_DLA_CPI','SHK_DLA_CPI_RW'});
g = addgroup(g,'Política Monetaria','SHK_RS');
g = addgroup(g,'Tipo de cambio','SHK_L_S');
g = addgroup(g,'Producto potencial',{'SHK_L_GDP_BAR','SHK_DLA_GDP_BAR'});
g = addgroup(g,'Demanda externa',{'SHK_L_GDP_RW_GAP'});
g = addgroup(g,'NAIRU','SHK_UNEM_BAR');
g = addgroup(g,'Crecimiento NAIRU','SHK_DLA_UNEM_BAR');

[dg,lg] = eval(g,s,'append',false);
lg{end} = 'Otros';

%% Graphs
% variables to graph
vars = {
	'L_GDP_GAP'		'Brecha del PIB'		'brecha_pib'		
	'UNEM'			'Tasa de desempleo'		'desempleo'
	'L_GDP_BAR'		'PIB tendencial'		'pib_pot'
	'UNEM_BAR'		'NAIRU'					'nairu'
	'D4L_CPI'		'Inflacion'				'inflacion'
};

% setting custom colors
colors = [
	31,120,180		% demanda
	51,160,44		% oferta
	152,78,163		% pm
	251,154,153		% tipo de cambio
	227,26,28		% pib potencial
	53,151,143		% externos
	254,224,139		% nairu
	255,127,0		% crec. nairu
	202,178,214		% otros
]/255;

set(0,'DefaultAxesColorOrder',colors)
set(0,'DefaultFigureWindowState','maximized')
set(0,'DefaultAxesFontName','Times New Roman')
set(0,'DefaultAxesFontSize',14)

for ii = 1:size(vars,1)
	figure('Color','w','Name',vars{ii,2},'NumberTitle','off')
	grid on
	bar(drange,dg.(vars{ii,1}),'stacked')
	xlabel('Periodo')
	ylabel('Contribución (%)')
	title(vars{ii,2},'FontSize',28)
	hold on
	if ii == 1
		plot(drange,d.(vars{ii,1}),'LineWidth',1,'Color','k')
		legend([lg ''],'Location','southwest','FontSize',12,'Box','on')
	elseif ii == 2
		legend(lg,'Location','northwest','FontSize',12,'Box','on')
	elseif ii == 3
		legend(lg,'Location','southwest','FontSize',12,'Box','on')
	elseif ii == 4
		legend(lg,'Location','northwest','FontSize',12,'Box','on')
	elseif ii == 5
		legend([lg ''],'Location','northwest','FontSize',12,'Box','on')
	else
		legend(lg,'Location','best','FontSize',12,'Box','on')
	end
	saveas(gcf,['seccion3\desc_' vars{ii,3} '.eps'],'epsc')
end

set(0,'DefaultAxesColorOrder','default')
set(0,'DefaultFigureWindowState','maximized')
set(0,'DefaultAxesFontName','default')
set(0,'DefaultAxesFontSize','default')