% Modelo costos de ajuste

var y l k;
varexo eps;
parameters BETA ALPHA c;
BETA = 0.99;
ALPHA = 2/3;
c = 20;

model;
y = k^ALPHA*l^(1-ALPHA);
l/(1-ALPHA) = 1/ALPHA*(k*(1+1/2*c*(k/k(-1)-1)^2)+k*c*(k/k(-1)-1)*k/k(-1)-BETA*c*(k(+1)*(k(+1)/k-1)*k(+1)/k));
log(l) = 0.9*log(l(-1)) + eps;
end;

steady_state_model;
l = 1;
k = ALPHA/(1-ALPHA);
y = k^ALPHA*l^(1-ALPHA);
end;

steady;

shocks;
var eps; stderr 0.01;
end;

stoch_simul(order=1,irf=30,nograph);

% figure;
% plot(0:options_.irf,oo_.y,'LineWidth',2);
% hold on
% plot(0:options_.irf,oo_.l,'LineWidth',2);
% plot(0:options_.irf,oo_.k,'LineWidth',2);

% Choque permanente
% choques = -0.01*ones(options_.irf,1);
% x = simult_(M_,options_,oo_.dr.ys,oo_.dr,choques,1);
% x_dev = x - oo_.dr.ys;
% t = 0:size(x(1,:),2)-1;
% 
% figure;
% for ii = 1:size(x,1)
% 	plot(t,x_dev(ii,:),'LineWidth',2)
% 	hold on
% end
% legend(M_.endo_names,'Location','northeast');