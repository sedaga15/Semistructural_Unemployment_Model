%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Graphs. Section 2 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%

%% Housekeeping
clear; clc;
close all;

%% Load data
d_bev = dbload('beveridge.csv');
d_perstd = dbload('pers_td.csv');
% d_contr = table2array(readtable('contrib.xlsx','Range','B2:O3'));

%% Plotting
% Common setup
set(0,'DefaultAxesFontName','Times New Roman')
set(0,'DefaultAxesFontSize',14)
set(0,'DefaultFigureWindowState','maximized')

% Beveridge curve
figure('Name','Beveridge curve','Color','w','NumberTitle','off')
plot(d_bev.T_UNEM.data,d_bev.T_VAC.data,'LineWidth',2,'Marker','square', ...
	 'Color',[227,26,28]/255)
text(d_bev.T_UNEM.data,d_bev.T_VAC.data,dat2str(dbrange(d_bev)), ...
	 'FontWeight','bold','FontName','Times New Roman','FontSize',13)
xlabel('Tasa de desempleo')
ylabel('Tasa de vacantes')
saveas(gcf,'figs\curva_beveridge.eps','epsc')

% Unemployment rate persistance
figure('Name','Unemployment rate persistance','Color','w','NumberTitle','off')
p1 = plot(d_perstd.OBS_UNEM,'LineWidth',2,'Color',[227,26,28]/255,'Marker','square');
text(p1.XData,d_perstd.OBS_UNEM.Data,string(d_perstd.OBS_UNEM.data), ...
	'FontWeight','bold','FontName','Times New Roman','FontSize',12)
hold on
plot(d_perstd.NAIRU,'LineWidth',2,'Color',[0,0,0]/255,'LineStyle','--')
ylabel('Porcentaje')
xlabel('Periodo')
legend([d_perstd.OBS_UNEM.Comment d_perstd.NAIRU.Comment])
% datxtick(mm(2020,1):mm(2022,12))
yticks([8 d_perstd.NAIRU.Data(1) 12 14 16 18 20 22])
x_tick = gca().XTick; x_tick(length(x_tick)+1) = 1.0e+03*2.02288; xticks(x_tick);
x_tick_lab = gca().XTickLabel; x_tick_lab{length(x_tick_lab)+1} = '2022M11'; xticklabels(x_tick_lab);
saveas(gcf,'figs\persistencia_td.eps','epsc')

% Contributions
% ramas = {
% 	'Act. Artísticas','Alojamiento','Admin. Pública','Construcción','Transporte',...
% 	'Act. Financieras','Comercio','Act. Profesionales','No informa','EGA*',...
% 	'Act. Inmobiliarias','Info. y Com.','Indus. Manuf','Agricultura'
% };
% figure('Name','Contributions','Color','w','NumberTitle','off')
% subplot(1,2,1)
% bar(categorical(ramas),d_contr(1,:))
% % text((1:length(ramas))',d_contr(1,:)',d_contr(1,:))
% title('2019')
% subplot(1,2,2)
% bar(categorical(ramas),d_contr(2,:))
% % text((1:length(ramas))',d_contr(2,:)',d_contr(2,:))
% title('2022')
% saveas(gcf,'figs\contribuciones.eps','epsc')



%% Revert to default
set(0,'DefaultAxesFontName','default')
set(0,'DefaultAxesFontSize','default')
set(0,'DefaultFigureWindowState','normal')