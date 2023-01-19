function report_filter(db,d_obs,K,mult,db_cont_obs,db_cont_sh,m,sdate,ehist,edate,...
                       vars_dec_obs,vars_dec_shk,num_sh,fldr,t0)

% Set defaults
set(groot,'DefaultFigureColormap',jet); close gcf
title = 'Colombia - Filtration';

decomp = false;
obs = false;
tables = false;
figures = false;
shocks = false;
tech_decomp = false;


% set ranges
rng2  = sdate:ehist;
rng = sdate:edate;
rng_bar = qq(2005,1):qq(2023,4);


%% Calculate OBS decompositions
if tech_decomp
    
var_plot_dec_obs = vars_dec_obs;

dec_obs_db = struct();
for vars = 1:length(var_plot_dec_obs)
    ddb = db_cont_obs.(var_plot_dec_obs{vars});
    names_full = strrep(get(ddb,'comments')','+','_');
    n = sum(abs(ddb),1);
    [~,ind] = sort(n,2,'descend');
    ind_get = ind(1:min(num_sh,length(n)-1));
    ind_rest= ind(min(num_sh+1,length(n)):end);
    
%     ind_get = 1:24;
    
    for ctbs = 1:num_sh
        dec_obs_db.(var_plot_dec_obs{vars}).(names_full{ind_get(ctbs)}(length(var_plot_dec_obs{vars})+9:end)) = ...
            Series(get(ddb,'range'),ddb(:,ind_get(ctbs)));
    end
    dec_obs_db.(var_plot_dec_obs{vars}).('other') = ...
            Series(get(ddb,'range'),sum(ddb(:,ind_rest),2));
    
end

 

%% Calculate and save SHOCK decompositions
if ~exist([fldr 'shk_dec_db/']) || ~isfolder([fldr 'shk_dec_db/'])
    mkdir([fldr 'shk_dec_db/']);
end


var_plot_dec_sh = vars_dec_shk;

dec_sh_db = struct();
for vars = 1:length(var_plot_dec_sh)
    ddb = db_cont_sh.(var_plot_dec_sh{vars});
    names_full = strrep(get(ddb,'comments')','+','_');
    n = sum(abs(ddb),1);
    [~,ind] = sort(n,2,'descend');
    ind_get = ind(1:min(num_sh,length(n)-1));
    ind_rest= ind(min(num_sh+1,length(n)):end);
    
%     ind_get = 1:24;
    
    for ctbs = 1:num_sh
        dec_sh_db.(var_plot_dec_sh{vars}).(names_full{ind_get(ctbs)}(length(var_plot_dec_sh{vars})+6:end)) = ...
            Series(get(ddb,'range'),ddb(:,ind_get(ctbs)));
    end
    dec_sh_db.(var_plot_dec_sh{vars}).('other') = ...
            Series(get(ddb,'range'),sum(ddb(:,ind_rest),2));

% Save the shock decomp databases

if ~exist([fldr 'results\shk_dec_db\']) || ~isfolder([fldr 'results\shk_dec_db\'])
    mkdir([fldr 'results\shk_dec_db\']);
end
databank.toCSV(dec_sh_db.(var_plot_dec_sh{vars}),[fldr 'results\shk_dec_db\' var_plot_dec_sh{vars} '.csv']);
        
end


end

%% Begin report
x = report.new(title);

% default figure style
sty = struct();
sty.line.linewidth = 1.5;
sty.line.linestyle = {'-';'--';'--'};
sty.line.color = {'k';'r';'g'};
sty.axes.box = 'off';
sty.legend.location='eastoutside';
sty.highlight.faceColor = [0.8,1,0.8];

% additional styles
sty2 = sty;
sty2.legend.location='southoutside';
sty2.legend.orientation = 'horizontal';


%% Observables - charts
if obs
    
style_obs = struct(); 
style_obs.line.marker = {'none','x'};
style_obs.line.lineStyle = {'-','none'};
style_obs.line.LineWidth = 1;
style_obs.axes.box = 'off';

vars_per_page = 9;
obsnames = intersect(dbnames(d_obs),get(m,'ylist'));
nPages   = ceil(numel(obsnames)/vars_per_page);

for iPage = 1:nPages
  
  x.figure(['Observables (page ', num2str(iPage) ' of ' num2str(nPages) ')'],...
                'dateformat','YYfP','range',sdate:ehist+8);
  
  if iPage == nPages
    for iObs = 1:(numel(obsnames)-(nPages-1)*vars_per_page)
      obsname = obsnames{(iPage-1)*vars_per_page+iObs};
      x.graph(obsname,'legend',false,'style',style_obs);
          x.series('',db.(obsname));
          if ~isempty(d_obs.(obsname))
              x.series('',d_obs.(obsname));
          end
      x.highlight('',ehist+1:edate);
    end
  else
    for iObs = 1:vars_per_page
      obsname = obsnames{(iPage-1)*vars_per_page+iObs};
      x.graph(obsname,'legend',false,'style',style_obs);
          x.series('',db.(obsname));
          if ~isempty(d_obs.(obsname))
              x.series('',d_obs.(obsname));
          end
      x.highlight('',ehist+1:edate);
    end
  end
  
end

end

%% Tables
% 
% if tables
%     
% x.table('Main Variables', 'range', ehist-6:ehist+12, 'vline', qq(2021,4),...
%         'decimal',1,'dateformat','YYFP');
% 
% x.subheading('GDP, Trend GDP, Output Gap');
%     x.series('GDP', (exp(db.L_GDP/100)/exp(db.L_GDP{-4}/100) -1 )*100, 'units', 'YoY');
%     x.series('',    (exp(db.L_GDP/100)/exp(db.L_GDP{-1}/100) -1 )*100, 'units', 'QoQ');
%     x.series('',    round(exp(db.L_GDP/100)/1000), 'units', 'Billions COP');
%     
%     x.series('Trend GDP', (exp(db.L_GDP_BAR/100)/exp(db.L_GDP_BAR{-4}/100)-1)*100, 'units', 'YoY');
%     x.series('',          (exp(db.L_GDP_BAR/100)/exp(db.L_GDP_BAR{-1}/100)-1)*100, 'units', 'QoQ');
%     x.series('',          round(exp(db.L_GDP_BAR/100)/1000), 'units', 'Billions COP');
%     x.series('Output Gap', db.DLA_CPI, 'units', 'in %');
%     
%     x.series('Annual Output Gap', db.D4L_GDP_GAP, 'units', 'in %');
% %     x.series('BanRep Annual Output Gap', db.Y_GDP_BR, 'units', 'in %');
%  %%   
% %     x.series('Annual Output Gap', db.Y_GDP_GAP, 'units', 'in %');
% %     x.subheading('');
% 
% %     x.series('BanRep Annual Output Gap', db.Y_GDP_BR, 'units', 'in %');
% %     x.subheading('');
%   %%  
% x.subheading('Monetary Policy');
%     x.series('Nominal Interest Rate', db.RS, 'units', 'in %');
%     x.subheading('');
%     
% x.subheading('CPI Inflation');
%     x.series('Inflation Target', db.D4L_CPI_TAR, 'units', '%YoY');
%     x.series('Inflation', db.D4L_CPI, 'units', '% YoY');
%     x.series('',          db.DLA_CPI, 'units', '% QoQ');
%     x.series('Core Inflation', db.D4L_CPIXFE, 'units', '% YoY');
%     x.series('',               db.DLA_CPIXFE, 'units', '% QoQ');
%     x.series('Regulated Inflation', db.D4L_CPIE, 'units', '% YoY');
%     x.series('',                    db.DLA_CPIE, 'units', '% QoQ');
%     x.series('Food Inflation', db.D4L_CPIF, 'units', '% YoY');
%     x.series('',               db.DLA_CPIF, 'units', '% QoQ');
%     x.subheading('');
%  
% x.subheading('Monetary Conditions');
%     x.series('Monetary Conditions Index', db.MCI, 'units', 'in %');
%     x.series('Real Interest Rate Gap',    db.RR_GAP, 'units', 'in %');
%     x.series('Real Exchange Gap',         db.L_Z_GAP, 'units', 'in %');
%     x.series('Premium Risk',              db.CR_PREM, 'units', 'in %');
%     x.subheading('');
%     
% x.subheading('Exchange Rate');
%     x.series('Nominal Exchange Rate', exp(db.L_S/100), 'units', 'COP');
%     x.series('', (exp(db.L_S/100)/exp(db.L_S{-1}/100)-1)*100, 'units', 'QoQ');
%     x.series('', (exp(db.L_S/100)/exp(db.L_S{-4}/100)-1)*100, 'units', 'YoY');
%     x.subheading('');
%    
% end


%% Figures

if figures
    
x.figure('Home economy','subplot',[3,3],...
         'style',sty2,'range',rng,'dateformat','YY:P');

x.graph('GDP','legend',false);
    x.series('',[db.L_GDP db.L_GDP_BAR]);
    x.highlight('',rng2);

x.graph('GDP growth YoY','legend',false);
    x.series('',[db.D4L_GDP db.D4L_GDP_BAR]);
    x.highlight('',rng2);

x.graph('Inflation and target','legend',true);
    x.series('QoQ',db.DLA_CPI);
    x.series('YoY',db.D4L_CPI);
    x.series('Target',db.D4L_CPI_TAR);
    x.highlight('',rng2);

x.graph('Nominal Exchange Rate','legend',false);
x.series('',[exp(db.L_S/100)]);
x.highlight('',rng2);

x.graph('Exchange Rate Depreciation','legend',false);
x.series('',db.DLA_S);
x.highlight('',rng2);

x.graph('Nominal Interest rate Rate','legend',false);
x.series('',db.RS);
x.highlight('',rng2);

x.graph('Food to Headline CPI','legend',false);
x.series('',[db.L_CPIF-db.L_CPI db.L_RPF_BAR]);
x.highlight('',rng2);

x.graph('Energy to Headline CPI','legend',false);
x.series('',[db.L_CPIE-db.L_CPI db.L_RPE_BAR]);
x.highlight('',rng2);

x.graph('"Core" to Headline CPI','legend',false);
x.series('',[db.L_CPIXFE-db.L_CPI db.L_RPXFE_BAR]);
x.highlight('',rng2);

x.pagebreak();

x.figure('Home economy - gaps','subplot',[3,3],...
         'style',sty,'range',rng,'dateformat','YY:P');

x.graph('Real Exchange Rate','legend',false);
x.series('',[db.L_Z db.L_Z_BAR]);
x.highlight('',rng2);

x.graph('Real Interest Rate','legend',false);
x.series('',[db.RR db.RR_BAR]);
x.highlight('',rng2);

x.graph('FX depreciation','legend',true,'style',sty2);
x.series('QoQ FX depr' ,db.DLA_S);
x.highlight('',rng2);

x.graph('RER gap','legend',false);
x.series('',[db.L_Z_GAP]);
x.highlight('',rng2);

x.graph('RIR gap','legend',false);
x.series('',[db.RR_GAP]);
x.highlight('',rng2);

x.graph('Monetary Conditions','legend',false);
x.series('',[db.MCI]);
x.highlight('',rng2);

x.graph('Output gap','legend',false);
x.series('',[db.L_GDP_GAP]);
x.highlight('',rng2);

x.graph('Inflation deviation (YoY)','legend',false);
x.series('',[db.D4L_CPI-db.D4L_CPI_TAR]);
x.highlight('',rng2);

x.graph('Relative price gaps','legend',true,'style',sty2);
x.series('energy',db.L_RPE_GAP);
x.series('food'  ,db.L_RPF_GAP);
x.series('implied core'  ,(-m.w_CPIF*db.L_RPF_GAP-m.w_CPIE*db.L_RPE_GAP)...
                           /(1-m.w_CPIF-m.w_CPIE));
x.highlight('',rng2);

x.pagebreak();

x.figure('External sector','subplot',[2,3],...
         'style',sty,'range',rng,'dateformat','YY:P');

x.graph('Foreign GDP','legend',false);
x.series('',[db.L_GDP_RW db.L_GDP_RW_BAR]);
x.highlight('',rng2);

x.graph('Foreign Output gap','legend',false);
x.series('',db.L_GDP_RW_GAP);
x.highlight('',rng2);

x.graph('Foreign Inflation (QoQ)','legend',false);
x.series('',[db.DLA_CPI_RW]);
x.highlight('',rng2);

x.graph('Foreign RIR and trend RIR','legend',false);
x.series('',[db.RR_RW db.RR_RW_BAR]);
x.highlight('',rng2);

x.graph('Foreign NIR','legend',false);
x.series('',[db.RS_RW]);
x.highlight('',rng2);

x.graph('Country Risk Premium','legend',false);
x.series('',[db.PREM db.PREM_BAR]);
x.highlight('',rng2);

x.pagebreak();

x.figure('Foreign gaps','subplot',[2,2],...
         'style',sty,'range',rng,'dateformat','YY:P');
    % 1 
    x.graph('Foreign Output Gap (in %)','legend',false);
    x.series('',[db.L_GDP_RW_GAP]);
    x.highlight('',rng2);     
    % 2
    x.graph('Real World Oil Price Gap (in %)','legend',false);
    x.series('',[db.L_RWOIL_GAP]);
    x.highlight('',rng2);     
    % 3
    x.graph('Real World Food Price Gap (in %)','legend',false);
    x.series('',[db.L_RWFOOD_GAP]);
    x.highlight('',rng2);     
    % 4
    x.graph('Foreign Real Interest Rate Gap (in pp)','legend',false);
    x.series('',[db.RR_RW_GAP]);
    x.highlight('',rng2);     
        
    
x.pagebreak();

x.figure('Commodities','subplot',[2,2],...
         'style',sty,'range',rng,'dateformat','YY:P');

x.graph('World oil price','legend',false);
x.series('',[exp((db.L_RWOIL + db.L_CPI_RW)/100) exp((db.L_RWOIL_BAR + db.L_CPI_RW)/100)]);
x.highlight('',rng2);

x.graph('World oil price gap','legend',false);
x.series('',[db.L_RWOIL_GAP]);
x.highlight('',rng2);

x.graph('World food price','legend',false);
x.series('',[db.L_RWFOOD db.L_RWFOOD_BAR]);
x.highlight('',rng2);

x.graph('World food price gap','legend',false);
x.series('',[db.L_RWFOOD_GAP]);
x.highlight('',rng2);

x.pagebreak();

end

%% Shock charts

if shocks
    
enms =  get(m,'enames');
pgs = ceil(length(enms)/9);

sty_sh = sty;
sty_sh.line.color = {'k';'r';'r'};

for i=1:pgs
    
    if i > 1
        x.pagebreak();
    end
    
    x.figure('','range',rng,'style',sty_sh,'figurescale',0.8);
    for j=1:min([9,length(enms)-(i-1)*9])
    std_plus  =  2*m.(['std_' enms{(i-1)*9+j}]).*mult.(['std_' enms{(i-1)*9+j}])*sqrt(K);
    std_minus = -2*m.(['std_' enms{(i-1)*9+j}]).*mult.(['std_' enms{(i-1)*9+j}])*sqrt(K);
        x.graph(enms{(i-1)*9+j},'zeroline',true);
            x.series('',dbeval(db,enms{(i-1)*9+j}));
            x.series('',std_plus);
            x.series('',std_minus);
            x.highlight('',rng2);
    end
end  

x.pagebreak();

end


%% Decompositions

% define styles
defstyle = struct;
defstyle.line.lineWidth = 2;
defstyle.figure.dateFormat = 'YYfP';

style_obs = defstyle;
style_obs.line.marker = {'none','x'};
style_obs.line.lineStyle = {'-','none'};
style1 = defstyle;
style1.line.marker = {'none','x'};
style1.line.lineStyle = {'-','none'};
barstyle = defstyle;
barstyle.line.lineWidth = {3,1.5};
barstyle.line.lineStyle = {'-','-','-','--'};
barstyle.line.color = {[1 1 1],[0 0 0],[1 1 1],[1 0 0]};
barstyle.legend.orientation = 'horizontal';
barstyle.legend.location = 'northoutside';
style2 = defstyle;
style2.axes.fontsize = 8;

bg = {'w','k','g','r'};
barclr = distinguishable_colors(10,bg); % first argument in a number of colors to be generated
barstyle.bar.FaceColor = {barclr(1:3)};
for clr = 1:size(barclr,1)-1
    barstyle.bar.FaceColor = [barstyle.bar.FaceColor {barclr(clr*3+1:clr*3+3)}];
end




if decomp
 
x.figure('Output gap','subplot',[2 1], 'style',defstyle,'range',rng_bar,...
         'dateformat','YYYY:P');
    x.graph('Output gap','legend',true);
        x.series('Estimated', db.L_GDP_GAP);
        x.series('Filtered', db.L_GDP_GAP - db.SHK_L_GDP_GAP);
        x.highlight('',rng2);
   x.graph('Contributions to Output gap','legend',true,'style', barstyle);
        x.series('',[db.b1 * db.L_GDP_GAP{-1}...
            db.b7 * db.E_L_GDP_GAP...
           -db.b2 * db.b4 * db.RR_GAP...
           -db.b2 * db.b4 * db.CR_PREM...
           -db.b2 * (1-db.b4) * (-db.L_Z_GAP)...
            db.b3 * db.L_GDP_RW_GAP...
            db.b6 * db.L_RWOIL_GAP...
            db.SHKN_L_GDP_GAP],...
        'Legend', {'Lag','Expect.','RIR gap','CR Prem','RER gap','RW Gap',...
                   'Oil Gap','Shock'},'plotfunc',@conbar);
        x.series('',      db.L_GDP_GAP,'legend',NaN);
        x.series('',      db.L_GDP_GAP,'legend',NaN);
        x.highlight('',rng2);
        
x.figure('Headline inflation, QoQ','subplot',[2 1], 'style',defstyle,...
                                   'range',rng_bar ,'dateformat','YYYY:P');
    x.graph('Headline inflation','legend',true);
        x.series('Total', db.DLA_CPI);
        x.series('Filtered', db.DLA_CPI - 4*db.SHK_L_CPI);
        x.highlight('',rng2);
   x.graph('Contributions to Headline inflation, QoQ','legend',true,'style', barstyle);
        x.series('',[db.w_CPIE*db.DLA_CPIE...
            db.w_CPIF*db.DLA_CPIF...
            (1-db.w_CPIE-db.w_CPIF)*db.DLA_CPIXFE...
            4*db.SHK_L_CPI],...
        'Legend', {'Energy','Food','Core','Discrepancy'},'plotfunc',@conbar);            
        x.series('',      db.DLA_CPI,'legend',NaN);
        x.series('',      db.DLA_CPI,'legend',NaN);
        x.highlight('',rng2);

x.figure('Core inflation, QoQ','subplot',[2 1], 'style',defstyle,'range',rng,'dateformat','YYYY:P');
    x.graph('Core inflation, QoQ','legend',true);
        x.series('Total', db.DLA_CPIXFE);
        x.series('Filtered', db.DLA_CPIXFE - db.SHK_DLA_CPIXFE);
        x.highlight('',rng2);
        
        
       

% MATLAB decomp example

% zz = [db.w_CPIE*db.DLA_CPIE...
%             db.w_CPIF*db.DLA_CPIF...
%             (1-db.w_CPIE-db.w_CPIF)*db.DLA_CPIXFE...
%             4*db.SHK_L_CPI];
% 
% barcon(zz);grid on; legeng('Energy','Food','Core','Discrepancy');
% hold on;
% plot(db.DLA_CPI,'color','k','linewidth',3);

        
x.figure('Core inflation','subplot',[2 1], 'style',defstyle,'range',rng_bar,...
         'dateformat','YYYY:P');
    x.graph('Core inflation','legend',true);
        x.series('Estimated', db.DLA_CPIXFE);
        x.series('Filtered', db.DLA_CPIXFE - db.SHK_DLA_CPIXFE);
        x.highlight('',rng2);        
        
    x.graph('Contributions to Core inflation, QoQ','legend',true,'style', barstyle);
        x.series('',[db.a1*db.DLA_CPIXFE{-1}...
                    (1-db.a1)*db.E_DLA_CPIXFE...
                     db.a2*db.a3*db.L_GDP_GAP...
                     db.a2*(1-db.a3)*db.L_Z_GAP...
                    -db.a2*(1-db.a3)*db.L_RPXFE_GAP...
                     db.SHK_DLA_CPIXFE],...
        'Legend', {'Lag','Lead','Output gap','RER gap','RP gap','Shock'},'plotfunc',@conbar);            
        x.series('',      db.DLA_CPIXFE,'legend',NaN);
        x.series('',      db.DLA_CPIXFE,'legend',NaN);
        x.highlight('',rng2);

        
x.figure('Food inflation, QoQ','subplot',[2 1], 'style',defstyle,'range',rng_bar,'dateformat','YYYY:P');
    x.graph('Food inflation, QoQ','legend',true);
        x.series('Total', db.DLA_CPIF);
        x.series('Filtered', db.DLA_CPIF - db.SHK_DLA_CPIF);
        x.highlight('',rng2);
   x.graph('Contributions to Food inflation, QoQ','legend',true,'style', barstyle);
        x.series('',[db.a21*db.DLA_CPIF{-1}...
                     (1-db.a21)*db.E_DLA_CPIF...
                     db.a22*db.a23*db.L_GDP_GAP...
                     db.a22*(1-db.a23)*db.L_Z_GAP...
                     db.a22*(1-db.a23)*db.L_RWFOOD_GAP...
                    -db.a22*(1-db.a23)*db.L_RPF_GAP...
                     db.SHK_DLA_CPIF],...
        'Legend', {'Lag','Lead','Output gap','RER gap','W.food gap',...
                   'RP gap','Shock'},'plotfunc',@conbar);            
        x.series('',      db.DLA_CPIF,'legend',NaN);
        x.series('',      db.DLA_CPIF,'legend',NaN);
        x.highlight('',rng2);

x.figure('Energy inflation, QoQ','subplot',[2 1], 'style',defstyle,'range',rng_bar,'dateformat','YYYY:P');
    x.graph('Energy inflation, QoQ','legend',true);
        x.series('Total', db.DLA_CPIE);
        x.series('Filtered', db.DLA_CPIE - db.SHK_DLA_CPIE);
        x.highlight('',rng2);
   x.graph('Contributions to Food inflation, QoQ','legend',true,'style', barstyle);
        x.series('',[db.a31*db.DLA_CPIE{-1}...
                     (1-db.a31)*db.E_DLA_CPIE...
                     db.a32*db.a33*db.L_GDP_GAP...
                     db.a32*(1-db.a33)*db.L_Z_GAP...
                    -db.a32*(1-db.a33)*db.L_RPE_GAP...
                     db.SHK_DLA_CPIE],...
        'Legend', {'Lag','Lead','Output gap','RER gap','RP gap','Shock'},...
                   'plotfunc',@conbar);            
        x.series('',      db.DLA_CPIE,'legend',NaN);
        x.series('',      db.DLA_CPIE,'legend',NaN);
        x.highlight('',rng2);
        
x.figure('Interest rate','subplot',[2 1], 'style',defstyle,'range',rng_bar,'dateformat','YYYY:P');
    x.graph('Interest rate','legend',true);
        x.series('Total', db.RS);
        x.series('Filtered', db.RS - db.SHK_RS);
        x.highlight('',rng2);
   x.graph('Contributions to Interest rate','legend',true,'style', barstyle);
        x.series('',[db.g1*db.RS{-1}...
                    (1-db.g1)*db.RSNEUTRAL...
                    (1-db.g1)*db.g2*db.D4L_CPI_DEV...
                    (1-db.g1)*db.g3*db.L_GDP_GAP...
                     db.SHK_RS],...
        'Legend', {'Lag','Neutral rate','Inflation deviation','Output gap','Shock'},'plotfunc',@conbar);            
        x.series('',      db.RS,'legend',NaN);
        x.series('',      db.RS,'legend',NaN);
        x.highlight('',rng2);
        
        
% x.figure('Premium and exchange rates','subplot',[2 2], 'style',defstyle,'range',rng_bar,'dateformat','YYYY:P');
%     x.graph('Premium','legend',true);
%         x.series('Total', db.PREM);
%         x.series('Filtered', db.PREM - db.SHKN_PREM);
%         x.highlight('',rng2);
%    x.graph('Contributions to Premium','legend',true,'style', barstyle);
%         x.series('',[db.RR_BAR...
%             -db.RR_RW_BAR...
%             -db.E_DLA_Z_BAR...
%             db.SHKN_PREM],...
%         'Legend', {'RIR trend','RIR US trend','RER trend','Shock'},'plotfunc',@conbar);            
%         x.series('',      db.PREM,'legend',NaN);
%         x.series('',      db.PREM,'legend',NaN);
%         x.highlight('',rng2);
%         


x.figure('Neutral interest rate', 'subplot',[1 1], 'style',defstyle,...
'range',rng_bar,'dateformat','YYYY:P');
x.graph('Contributions to Headline inflation, QoQ','legend',true,...
'style',barstyle);
x.series('',[db.RR_RW_BAR db.PREM_BAR db.DLA_Z_BAR db.E_D4L_CPI1],...
'Legend', {'Ext.trend RIR','PREM trend ','RER trend','Exp.Infl(YoY)'},...
'plotfunc',@conbar);
x.series('', db.RSNEUTRAL,'legend',NaN);
x.series('', db.RSNEUTRAL,'legend',NaN);
x.highlight('',rng2);


% Real Exchange Rate
x.figure('Real Exchange Rate', 'subplot', [2 1],'style',defstyle,'range',...
         rng,'dateformat','YYYY:P');
    x.graph('Core inflation', 'legend', true);
        x.series('Total', db.L_S)
%         x.series('Filtered', db.L_S);
        x.highlight('',rng2);
        
    x.graph('Contributions to Real Exchange Rate','legend',true,'style', barstyle);
        x.series('',[db.L_S ...
                     db.L_CPI_RW ...
                     -db.L_CPI],...
            'Legend', {'Nominal Exc. Rate','For. CPI','Dom. CPI'},'plotfunc',@conbar);
            x.series('',      db.DLA_CPIXFE,'legend',NaN);
            x.series('',      db.DLA_CPIXFE,'legend',NaN);
            x.highlight('',rng2);
   
% Nominal Interest Rate
x.figure('Nominal Interest Rate', 'subplot', [2 1],'style',defstyle,...
         'range',rng,'dateformat','YYYY:P');
    x.graph('Nominal Interest Rate', 'legend', true);
        x.series('Total', db.RS)
%         x.series('Filtered', db.RS - 4*db.SHK_RS);
        x.highlight('',rng2);
        
    x.graph('Contributions to Nominal Interest Rate','legend',true,'style', barstyle);
        x.series('',[db.g1* db.RS{-1} ...
                (1-db.g1)*db.RSNEUTRAL...
                (1-db.g1)*db.g2*db.E_D4L_CPI3...
                (1-db.g1)*db.g2*db.D4L_CPI_TAR... 
                (1-db.g1)*db.g3*db.L_GDP_GAP...
                db.SHK_RS],...
            'Legend', {'Lag','Neutral Nom. Rate','Exp. Inflation',...
                    'Inflation Target','GDP gap','Nom. Int. Shock'},'plotfunc',@conbar);
            x.series('',      db.RS,'legend',NaN);
            x.series('',      db.RS,'legend',NaN);
            x.highlight('',rng2); 



end


x.pagebreak;
%% OBS decompositions

if tech_decomp

fnms = fieldnames(dec_obs_db);


barstyle_d = barstyle;
barstyle_d.legend.orientation = 'vertical';
barstyle_d.legend.location = 'eastoutside';

bg = {'w','k','g','r'};
barclr = distinguishable_colors(length(fieldnames(dec_obs_db.(fnms{1}))),bg);
barstyle_d.bar.FaceColor = {barclr(1:3)};
for clr = 1:size(barclr,1)-1
    barstyle_d.bar.FaceColor = [barstyle_d.bar.FaceColor {barclr(clr*3+1:clr*3+3)}];
end


for nn = 1:length(fnms)
    vars2plot = fields(dec_obs_db.(fnms{nn}));
    bars2plot = dec_obs_db.(fnms{nn}).(vars2plot{1});
    for barzz = 2:length(vars2plot)
        bars2plot = [bars2plot dec_obs_db.(fnms{nn}).(vars2plot{barzz})];
    end
    
x.figure('Decomposition of OBS variables impact','subplot',[2 1], 'style',barstyle_d,'range',rng,'dateformat','YYYY:P');
   x.graph(fnms{nn},'legend',true,'style', barstyle_d);
        x.series('',bars2plot,...
        'Legend', strrep(fields(dec_obs_db.(fnms{nn}))','_','\_'),...
        'plotfunc',@conbar);            
        x.series('',      db.(fnms{nn}),'legend',NaN);
        x.series('',      db.(fnms{nn}),'legend',NaN);
        x.highlight('',rng2);
end
        
        
        
x.pagebreak;
%% SHK decompositions
fnms = fieldnames(dec_sh_db);


barstyle_d = barstyle;
barstyle_d.legend.orientation = 'vertical';
barstyle_d.legend.location = 'eastoutside';

bg = {'w','k','g','r'};
barclr = distinguishable_colors(length(fieldnames(dec_sh_db.(fnms{1}))),bg);
barstyle_d.bar.FaceColor = {barclr(1:3)};
for clr = 1:size(barclr,1)-1
    barstyle_d.bar.FaceColor = [barstyle_d.bar.FaceColor {barclr(clr*3+1:clr*3+3)}];
end


for nn = 1:length(fnms)
    vars2plot = fields(dec_sh_db.(fnms{nn}));
    bars2plot = dec_sh_db.(fnms{nn}).(vars2plot{1});
    for barzz = 2:length(vars2plot)
        bars2plot = [bars2plot dec_sh_db.(fnms{nn}).(vars2plot{barzz})];
    end
    
x.figure('SHOCK decompositions','subplot',[2 1], 'style',barstyle_d,'range',rng,'dateformat','YYYY:P');
   x.graph(fnms{nn},'legend',true,'style', barstyle_d);
        x.series('',bars2plot,...
        'Legend', strrep(fields(dec_sh_db.(fnms{nn}))','_','\_'),...
        'plotfunc',@conbar);            
        x.series('',      db.(fnms{nn}),'legend',NaN);
        x.series('',      db.(fnms{nn}),'legend',NaN);
        x.highlight('',rng2);
end
        
        
        
       
        
end       
        


%% Shock table

if shocks
pgs = ceil(length(sdate:edate)/16);

for ip = 2:pgs
    
    x.table('Shocks','range',sdate+16*(ip-1):min([sdate+16*(ip)-1,edate]),...
            'dateformat',{'YYYY','%qR'},...
            'vline',qq(dat2ypf(sdate+16*(ip-1)),4):4:min([sdate+16*(ip)-1,edate]),... 
            'arrayStretch',1.25,...
            'highlight',sdate+16*(ip-1):ehist,'tabcolsep',0.2,'dd',1);
    enms =  get(m,'enames');
        for is=1:length(enms)
            x.series(enms{is}, dbeval(db,enms{is}));
        end
    x.pagebreak();
end

end

%% Yearly numbers
%{
% non-log variables for gdp
list = {'L_GDP','L_GDP_BAR'};
db = dbbatch(db,'$1','exp(db.$0/100)','nameFilter=','L_(.*)','namelist',list); 

% create yearly numbers
% averages
y_avg = dbbatch(db,'$0','convert(db.$0,''y'')', 'classFilter=','Series','fresh',true);  
% end of period
list  = {'L_S','D4L_CPI'};
y_eop = dbbatch(db, '$0_eop', 'convert(db.$0, ''y'',Inf,''method'',@last)','namelist', list,'fresh',true); 
% sum
list = {'GDP','GDP_BAR'};
y_sum = dbbatch(db, '$0', 'convert(db.$0, ''y'',Inf,''method'',@sum)','namelist', list,'fresh',true);  

% merge databases
y     = dbmerge(y_avg,y_eop,y_sum);
rng_tbl_y = yy(2019):yy(2023);
x.table('Yearly Indicators','range',rng_tbl_y,'vline',yy(2021),'decimal',1,'dateformat','YYYY','footnote','just in case I want a footnote');
x.subheading('Inflation');
    x.series('CPI Inflation',       y.D4L_CPI,     'units', '% avg');
    x.series('CPI Inflation',       y.D4L_CPI_eop, 'units', '% eop');
    x.series('Inflation Target',    y.D4L_CPI_TAR, 'units', '%');
    x.subheading('');  
x.subheading('Interest Rate (SAY WHICH ONE)');
    x.series('Nominal policy rate', y.RS,      'units', '% p.a., avg');
    x.series('ZLB Nominal rate',    y.RS,          'units', '% p.a., avg');
    x.series('Real',                y.RR,          'units', '% p.a., avg');
    x.subheading('');
x.subheading('Exchange rate');
    x.series('COP per USD',       exp(y.L_S/100), 'units', 'avg');
    x.series('COP per USD',       exp(y.L_S_eop/100), 'units', 'eop');
    x.series('Nom. Depreciation', y.D4L_S, 'units', '% avg');
    x.series('Real Depreciation', y.D4L_Z, 'units', '% avg');
    x.subheading('');
x.subheading('Real GDP');
    x.series('Growth)',           pct(y.GDP), 'units', '%');
    x.series('Output Gap',        y.L_GDP_GAP , 'units', '% avg');
    x.series('Potential Growth' , pct(y.GDP_BAR), 'units', '%');
    x.subheading('');
x.subheading('External sector variables');
    x.series('RW Interest Rate (WHICH ONE)', y.RS_RW, 'units', '% p.a. avg'); 
%     x.series('RW CPI inflation',      y.D4L_CPI_RW, 'units', '% avg'); 
    x.series('Oil Price',             exp(y.L_WOIL/100),   'units', 'USD per barrel, avg'); 
x.pagebreak();
%}


%% compile and save the report

if ~exist([fldr 'reports/']) || ~isfolder([fldr 'reports\'])
    mkdir([fldr 'reports/']);
end

try
    x.publish([fldr 'reports\filter_report' sfx '_' datestr(now,...
               'yyyymmmdd_HHMMSS') '.pdf'],'display',false);
catch
    x.publish([fldr 'reports\filter_report_' datestr(now,'yyyymmmdd_HHMMSS') ...
                '.pdf'],'display',false);
end
disp('Report done!');

