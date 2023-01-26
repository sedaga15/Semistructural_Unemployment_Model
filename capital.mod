% Modelo costos de ajuste

var y l k;
varexo eps;
parameters BETA ALPHA RHO c lss;
BETA = 0.99;
ALPHA = 0.33;
c = 20;
RHO = 0.9;
lss = 1;

model;
y = k^ALPHA*l^(1-ALPHA);
l/(1-ALPHA) = 1/ALPHA*(k*(1+1/2*c*(k/k(-1)-1)^2)+k*c*(k/k(-1)-1)*k/k(-1)-BETA*c*(k(+1)*(k(+1)/k-1)*k(+1)/k));
l = RHO*l(-1) + (1-RHO)*lss - eps;
end;

@#ifdef STOCH
steady_state_model;
l = lss;
k = (ALPHA*l)/(1-ALPHA);
y = k^ALPHA*l^(1-ALPHA);
end;
steady;
shocks;
var eps; stderr 1;
end;
stoch_simul(order=1,irf=30,nograph);
figure;
plot(0:options_.irf-1,oo_.irfs.y_eps,'LineWidth',2);
hold on
plot(0:options_.irf-1,oo_.irfs.l_eps,'LineWidth',2);
plot(0:options_.irf-1,oo_.irfs.k_eps,'LineWidth',2);
legend({'Output' 'Labor' 'Capital'},'Location','northeast');
@#else
initval;
% l = lss;
% k = (ALPHA*l)/(1-ALPHA);
% y = k^ALPHA*l^(1-ALPHA);
eps = 0;
end;
steady;
endval;
eps = -0.5;
end;
steady;
perfect_foresight_setup(periods=30);
perfect_foresight_solver;
rplot y k l;
@#endif


% figure;
% plot(0:options_.irf-1,oo_.irfs.y_eps,'LineWidth',2);
% hold on
% plot(0:options_.irf-1,oo_.irfs.l_eps,'LineWidth',2);
% plot(0:options_.irf-1,oo_.irfs.k_eps,'LineWidth',2);
% legend({'Output' 'Labor' 'Capital'},'Location','northeast');

% Choque permanente
choques = -1*ones(options_.irf,1);
x = simult_(M_,options_,oo_.dr.ys,oo_.dr,choques,1);
x_dev = x - oo_.dr.ys;
t = 0:size(x(1,:),2)-1;

figure;
for ii = 1:size(x,1)
	plot(t,x_dev(ii,:),'LineWidth',2)
	hold on
end
legend(M_.endo_names,'Location','northeast');