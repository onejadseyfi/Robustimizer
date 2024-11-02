function [GP]=fitGP(DOE,Ninp,Response)

regr = str2num('@regpoly0');
corr = str2num('@corrgauss');
t0 = zeros(1,Ninp);
tcon = [1e-5 1000]; 
lob = tcon(1) * ones(size(t0));
upb = tcon(2) * ones(size(t0));

    for i = 1 : length(Response(1,:))
        
        % Fit the metamodel using Dace model
        [dmodel] = dacefit(DOE,Response(:,i),regr,corr,t0,lob,upb);
        tver1 = abs(diff([dmodel.theta;lob])) < 1e-10;
        tver2 = abs(diff([dmodel.theta;upb])) < 1e-10;
    
        if any(tver1) == 1 | any(tver2) == 1
            warndlg(sprintf('Metamodel fitting warning for response %s, The matrix is ill-conditioned, Check DOE and results and try again',num2str(i)))
        end
    
        GP(i)=struct('dmodel',dmodel);
    end

end
