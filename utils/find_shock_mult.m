function [mNew,paramNew,stdNew,a,b,mult]=find_shock_mult(a,b,eps,N,param,model,dd,range,std_list,std)

  warning('off','IRIS:Dbase:NameNotExist');

  c = (-1+sqrt(5))/2;
  x1 = c*a + (1-c)*b;
  x2 = (1-c)*a + c*b;

  pp=dbbatch(std,'$0','x1*std.$0','namelist',std_list);
  p=dbbatch(param,'$0','x1*param.$0','namelist',std_list);
  m = assign(model, p);
  m = solve(m);
  m = sstate(m); %,'Growth',true,'Display','off','block',true,'solver','fsolve');
  fx1 = loglik(m,dd,range,'deviation',false,'std',pp,'relative',false);
  
  pp=dbbatch(std,'$0','x2*std.$0','namelist',std_list);
  p=dbbatch(param,'$0','x2*param.$0','namelist',std_list);
  m = assign(model, p);
  m = solve(m);
  m = sstate(m); %,'Growth',true,'Display','off','block',true,'solver','fsolve');
  fx2 = loglik(m,dd,range,'deviation',false,'std',pp,'relative',false);

%   fprintf('------------------------------------------------------\n');
%   fprintf(' x1 x2 f(x1) f(x2) b - a\n');
%   fprintf('------------------------------------------------------\n');
%   fprintf('%.4e %.4e %.4e %.4e %.4e\n', x1, x2, fx1, fx2, b-a);
  for i = 1:N-2
    if fx1 < fx2
      b = x2;
      x2 = x1;
      fx2 = fx1;
      x1 = c*a + (1-c)*b;
      pp=dbbatch(std,'$0','x1*std.$0','namelist',std_list);
      p=dbbatch(param,'$0','x1*param.$0','namelist',std_list);
      m = assign(model, p);
      m = solve(m);
      m = sstate(m); %,'Growth',true,'Display','off','block',true,'solver','fsolve');
      fx1 = loglik(m,dd,range,'deviation',false,'std',pp,'relative',false);
    else
      a = x1;
      x1 = x2;
      fx1 = fx2;
      x2 = (1-c)*a + c*b;
      pp=dbbatch(std,'$0','x2*std.$0','namelist',std_list);
      p=dbbatch(param,'$0','x2*param.$0','namelist',std_list);
      m = assign(model, p);
      m = solve(m);
      m = sstate(m); %,'Growth',true,'Display','off','block',true,'solver','fsolve');
      fx2 = loglik(m,dd,range,'deviation',false,'std',pp,'relative',false);
    end
%     fprintf('%.4e %.4e %.4e %.4e %.4e\n', x1, x2, fx1, fx2, b-a);
    if (abs(b-a) < eps)
      fprintf('succeeded after %d steps\n', i);
      mult=(a+b)/2;
      stdNew=dbbatch(std,'$0','mult*std.$0','namelist',std_list);
      paramNew=dbbatch(param,'$0','mult*param.$0','namelist',std_list);
      mNew = assign(model,paramNew);
      mNew = solve(mNew);
      mNew = sstate(mNew); %,'Growth',true,'Display','off','block',true,'solver','fsolve');
      stdvec = get(mNew, 'stdvec');
      enames = get(mNew, 'elist');
      for ii=1:numel(enames)
         try stdvec(ii,:) = paramNew.(['std_' enames{ii}]);
         catch
             disp(['no parameter specified:' '  std_' enames{ii}]);
         end
      end
      set(mNew, 'stdvec', stdvec);
      return;
    end
  end
  fprintf('failed requirements after %d steps\n', N);
  
  warning('on','IRIS:Dbase:NameNotExist');
end