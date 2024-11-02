% Robustimizer - Copyright (c) 2024 Omid Nejadseyfi
% Licensed under the GNU General Public License v3.0, see LICENSE.md.
function [Noisestruct,mu,sigma,dMu,dSigma,s_hat,skew]= AnalyticalKrigX(designInput,Inp,srgModel,position,FirstEval,Noisestruct,Flag)

% This function propagates the noise via surrogate model and returns the
% characteristics of output distribution using analytical evaluation 

% Input: 

% Inp             structure containing the input required for optimization
% optCnd          structure containing the settings of optimziation
% designInput     the design DOE point
% srgtModel       surrogate model structure
% firstEval       parameter accounting for the repeating of the evaluation to avoid repetitive calculations
% Passnoise_distr the noise distribution
% srgtModel       surrogate model structure
% DOEn            noise DOE
% position        the position in which the surrogate model is evaluated
% Noisestruct     Noise structure to be used in future evaluations
% Flag            Flag to see if the noise structure exists to avoid repetitive evaluations 

% OutPut: 
% mu            mean of the output
% sigma         standard deviation of the output
% skew          skewness of the output
% s_hat         uncertainty of the model
% dMu           derivative of the mean of the output
% dSigma        derivative of the standard deviation of the output

%Assigning input and optimization condition from input file
outID=Inp.outID;
DOE=Inp.DOE;
gradRequire=0; %Future development
nDesVar=Inp.nDesVar;
nNoiVar=Inp.nNoiVar;
noiDistr=Inp.noiDistr;

muNoise=noiDistr(:,1)';
stdevNoise=noiDistr(:,2)';
dmodel0Krig=srgModel(1,position).dmodel;
% Initialize
gamma=dmodel0Krig.gamma;        % The factors for Kriging (Ordinary kriginig)
x_input=dmodel0Krig.S';         % Simple DOE here
b0=dmodel0Krig.beta;            % Mean value in case of 0th order kriginig
teta=dmodel0Krig.theta;         % Fitting parameters
d_input=x_input(1:nDesVar,:);
n_input=x_input(nDesVar+1:nDesVar+nNoiVar,:);
teta_design=teta(:,1:nDesVar);
teta_noise=teta(:,nDesVar+1:nDesVar+nNoiVar);
Ssc=dmodel0Krig.Ssc;
Ysc=dmodel0Krig.Ysc;
sigma2=dmodel0Krig.sigma2;
N_DOE=size(DOE,1);               % Number of DOE points
%Calculating mean
%Calculating C1iq for noise variables only once for each design point.
%This is based on equation (31) paper O.nejadseyfi et al. 2018 engineering optimization
if FirstEval==1 && Flag==0 %There is no need to calculate the matrices at all iterations of the optimization, therefore they are only evaluated once
    Mu_input_Scaled=(muNoise - Ssc(1,nDesVar+1:nDesVar+nNoiVar)) ./ Ssc(2,nDesVar+1:nDesVar+nNoiVar);
    Sigma_input_scaled=(stdevNoise ./ Ssc(2,nDesVar+1:nDesVar+nNoiVar));
    Mu_input_Aug=repmat(Mu_input_Scaled,[N_DOE,1]);
    C1iq_scaled_krig(:,:,:,position)=repmat((1./sqrt(2*Sigma_input_scaled.^2.*teta_noise+1)),[N_DOE,1]).*exp(-repmat((teta_noise./(2.*Sigma_input_scaled.^2.*teta_noise+1)),[N_DOE,1]).*(Mu_input_Aug-n_input').^2);
    prodL_C1iq(:,:,:,position)=prod(C1iq_scaled_krig(:,:,:,position),2);
    Noisestruct(1).prodL_C1iq(:,:,:,position)=prodL_C1iq(:,:,:,position);      %(1) is used since at first evaluation the struct is empty        %store for later use. This prevents to calculate the same tensor each time, saves calculation time.
    Noisestruct.C1iq_scaled_krig(:,:,:,position)=C1iq_scaled_krig(:,:,:,position);  %store for later use
else
    prodL_C1iq(:,:,:,position)=Noisestruct.prodL_C1iq(:,:,:,position);
    C1iq_scaled_krig(:,:,:,position)=Noisestruct.C1iq_scaled_krig(:,:,:,position);
end
%Calculating Bip based on equation (30) same paper
design_input_scaled=bsxfun(@rdivide,bsxfun(@minus,designInput,(Ssc(1,1:nDesVar))),(Ssc(2,1:nDesVar)));
Bip=exp(-bsxfun(@times,teta_design,((bsxfun(@minus,design_input_scaled,d_input')).^2)));
prod_Bip=prod(Bip,2);
prod_total=prodL_C1iq(:,:,:,position).*prod_Bip;

% Mean value based on equation (A.1) same paper
MuY_scaled=b0+sum(prod_total.*gamma'); %Eq 3.1 in Wei chen et al
mu = (Ysc(1,:) + Ysc(2,:) .* MuY_scaled)';

%Derivative of mu based on equation (26) same paper
if nargout > 3 %more output requested rather than only mean and stdev
    if gradRequire==1 %gradient required
        dBip=-2*repmat(teta_design,[N_DOE,1]).*(design_input_scaled-d_input').*exp(-repmat(teta_design,[N_DOE,1]).*(design_input_scaled-d_input').^2);
        dB1iloverHil=dBip./Bip;
        prod_total_derivative=repmat(prod_total,1,size(dB1iloverHil,2)).*dB1iloverHil;
        Grad_MuY_scaled=prod_total_derivative'*gamma';   %Chk lines 55 to 65 Predictor to find the unscaled value
        Grad_Mu_Unscal=(Ysc(2,:)./(Ssc(2,1:nDesVar))).* Grad_MuY_scaled';
        dMu=permute(Grad_Mu_Unscal,[2 1]);
    else
        dMu=zeros(nDesVar,1);
    end
end

% Calculating STDev
% Calculate C2ijq based on equation (33). On each design point this tensor 
% is calculated only once to save computational time
% We extend the size of tensor in 3rd direction (j) to do all calculations
% at once. This is much faster than a "for" loop. might cause memory issues
% for large matrix size

if FirstEval==1 && Flag==0
    n_input_2ndDirection=(n_input');
    n_input_3rdDirection=permute(n_input',[3 2 1]);
    %terms 1 to 6 are parts of the equation (33) that are split to
    %cauculate separately. They are joined at the end to calculate C2ijq_scaledKrig 
    t1=bsxfun(@rdivide,1,sqrt(4*Sigma_input_scaled.^2.*teta_noise+1));
    t2=-(teta_noise./(4.*Sigma_input_scaled.^2.*teta_noise+1));
    t3=bsxfun(@minus,Mu_input_Scaled,n_input_2ndDirection);
    t4=bsxfun(@minus,Mu_input_Scaled,n_input_3rdDirection);
    t5=(2*Sigma_input_scaled.^2.*teta_noise);
    t6=bsxfun(@minus,n_input_2ndDirection,n_input_3rdDirection);
    C2ijq_scaledKrig(:,:,:,position)=bsxfun(@times,t1,exp(bsxfun(@times,t2,bsxfun(@plus,bsxfun(@plus,bsxfun(@power,t3,2),bsxfun(@power,t4,2)),bsxfun(@times,t5,bsxfun(@power,t6,2))))));  %Eq 3.18
    C1iqC1jq_scaledKrig(:,:,:,position)=bsxfun(@times,C1iq_scaled_krig(:,:,:,position),permute(C1iq_scaled_krig(:,:,:,position),[3,2,1,4]));
    %Multiplication of "a_i*a_j" in equation (27) same paper
    a1a2=bsxfun(@times,gamma',gamma);
    a1a2permuted(:,:,:,position)=permute(a1a2,[1,3,2]);
    prod1prod2(:,:,:,position)=bsxfun(@times,prod(C1iqC1jq_scaledKrig(:,:,:,position),2),[bsxfun(@minus,prod(bsxfun(@rdivide,C2ijq_scaledKrig(:,:,:,position),C1iqC1jq_scaledKrig(:,:,:,position)),2),ones((size(n_input,2)),1,size(n_input,2)))]);
    Prod_tot(:,:,:,position)=bsxfun(@times,a1a2permuted(:,:,:,position),prod1prod2(:,:,:,position));
    Noisestruct.prod1prod2(:,:,:,position)=prod1prod2(:,:,:,position);      %store for later use. This prevents to calculate the same tensor each time, saves calculation time.
    Noisestruct.a1a2permuted(:,:,:,position)=a1a2permuted(:,:,:,position);  %store for later use
    Noisestruct.Prod_tot(:,:,:,position)=Prod_tot(:,:,:,position);          %store for later use
    Noisestruct.C2ijq_scaledKrig(:,:,:,position)=C2ijq_scaledKrig(:,:,:,position);  %store for later use
else
    prod1prod2(:,:,:,position)=Noisestruct.prod1prod2(:,:,:,position);
    a1a2permuted(:,:,:,position)=Noisestruct.a1a2permuted(:,:,:,position);
    Prod_tot(:,:,:,position)=Noisestruct.Prod_tot(:,:,:,position);
    C2ijq_scaledKrig(:,:,:,position)=Noisestruct.C2ijq_scaledKrig(:,:,:,position);
end

%Calculate B1ipB1jp
BipBjp=bsxfun(@times,Bip,permute(Bip,[3,2,1]));
prod_design=prod(BipBjp,2);
% Calculate STDev equation (27)
StdevY_scaled=sqrt(abs(sum(sum(bsxfun(@times,Prod_tot(:,:,:,position),prod_design))))); %Eq 3.3
sigma = (Ysc(2,:) .* StdevY_scaled)';
% Derivative of STDev
if nargout > 4 % More output requested rather than only mean and stdev
    if gradRequire==1 % Gradient required
        dBip=-2*repmat(teta_design,[N_DOE,1]).*(design_input_scaled-d_input').*exp(-repmat(teta_design,[N_DOE,1]).*(design_input_scaled-d_input').^2);
        BipdBjp=repmat(Bip,[1,1,N_DOE]).*repmat(permute(dBip,[3,2,1]),[N_DOE,1,1]);
        dBipBjp=repmat(dBip,[1,1,N_DOE]).*repmat(permute(Bip,[3,2,1]),[N_DOE,1,1]);
        prod_total_deriv_U=(BipdBjp+dBipBjp)./BipBjp;
        d_SigmaY_scaled=sum(sum(repmat(a1a2permuted(:,:,:,position).*prod1prod2(:,:,:,position).*prod_design,[1,size(teta_design,2),1]).*(prod_total_deriv_U)./(2*StdevY_scaled),1),3); %make this line correvct size theta design and what?  %
        grad_SigmaY_unscal=((Ysc(2,:)./(Ssc(2,1:size(dB1iloverHil,2)))).*d_SigmaY_scaled);
        dSigma=permute(grad_SigmaY_unscal,[2 1]);
    else
        dSigma=zeros(nDesVar,1); 
    end
end
%S_Hat based on (45) same paper
if nargout > 5 %S_hat required
    yminusz=permute((repmat(x_input,[1,1,N_DOE])),[1,3,2])-(repmat(x_input,[1,1,N_DOE]));
    R_outofPlane=exp(-sum((yminusz.^2.*repmat(teta',[1,N_DOE,N_DOE])),1));
    R=permute(R_outofPlane,[2,3,1]); %should be symmetric in this case
    C2ij_Shat=prod(permute(C2ijq_scaledKrig(:,:,:,position),[1,3,2]),3);
    ProdH=prod(permute(BipBjp,[1,3,2]),3);
    s_hat2=sigma2*(1-(sum(sum(inv(R).*(C2ij_Shat.*ProdH)))));%*(sum(sum(prod(H1i1H1i2,2))));
    s_hat=sqrt(abs(s_hat2));
end
%Calculate Skewness  
%Calculation of C3_ijkq avoiding memory overflow
if nargout > 6 %Skewness required
    SumSplitdirection=0;
    N_bin=100;
    bin_size=N_bin;
    if (mod(size(DOE,1),bin_size))==0
        loopsize=(size(DOE,1)/bin_size);
    else
        loopsize=((size(DOE,1)-mod(size(DOE,1),bin_size))/bin_size)+1;
    end
    for counter=1:loopsize
        if  (mod(size(DOE,1),bin_size))==0   
            bin_size=N_bin;
            IndexBegin=1+(counter-1)*N_bin;
            IndexEnd=(counter)*N_bin;
        else
            if counter==1
                IndexBegin=1;
                IndexEnd=mod(N_DOE,bin_size);
                bin_size=mod(size(DOE,1),bin_size);
            else
                bin_size=N_bin;
                IndexBegin=1+mod(N_DOE,bin_size)+(counter-2)*bin_size;
                IndexEnd=mod(N_DOE,bin_size)+(counter-1)*bin_size;
            end
        end
        
        if FirstEval==1  && Flag==0
            n_inv=n_input';
            if counter==1||counter==2
                n_input_2ndDirection_skewKr=repmat((n_inv),[1,1,N_DOE,bin_size]);
                n_input_3rdDirection_skewKr=repmat(permute(n_inv,[3 2 1 4]),[N_DOE,1,1,bin_size]);
            end
            n_input_4thDirection_skewKr=repmat(permute(n_inv((IndexBegin:IndexEnd),:,:,:),[4 2 3 1]),[N_DOE,1,N_DOE,1]);
            if counter==1||counter==2
                t1_skewKr=repmat((1./sqrt(6*Sigma_input_scaled.^2.*teta_noise+1)),[N_DOE,1,N_DOE,bin_size]);
                t2_skewKr=-repmat((teta_noise./(6.*Sigma_input_scaled.^2.*teta_noise+1)),[N_DOE,1,N_DOE,bin_size]);
                t3A_skewKr=repmat(repmat(Mu_input_Scaled,N_DOE,1)-(n_inv),[1,1,N_DOE,bin_size]);
                t3B_skewKr=(repmat(Mu_input_Scaled,[N_DOE,1,N_DOE,bin_size])-(n_input_3rdDirection_skewKr));
            end
            t3C_skewKr=(repmat(Mu_input_Scaled,[N_DOE,1,N_DOE,bin_size])-(n_input_4thDirection_skewKr));
            if counter==1||counter==2
                t5_skewKr=repmat((2*Sigma_input_scaled.^2.*teta_noise),[N_DOE,1,N_DOE,bin_size]);
                t6A_skewKr=(n_input_2ndDirection_skewKr-n_input_3rdDirection_skewKr);
            end
            t6B_skewKr=(n_input_2ndDirection_skewKr-n_input_4thDirection_skewKr);
            t6C_skewKr=(n_input_3rdDirection_skewKr-n_input_4thDirection_skewKr);
            gamma_inv=gamma';       
            if counter==1
                C3ijkl_KrigScaled_1st(:,:,:,:,position,counter)=t1_skewKr.*exp(t2_skewKr.*(t3A_skewKr.^2+t3B_skewKr.^2+t3C_skewKr.^2+(t5_skewKr.*(t6A_skewKr.^2+t6B_skewKr.^2+t6C_skewKr.^2))));  %Eq 3.18
                C1i1C1i2C1i3l_scaledSkew_1st(:,:,:,:,position,counter)=repmat(C1iq_scaled_krig(:,:,:,position),[1,1,N_DOE,bin_size]).*repmat(permute(C1iq_scaled_krig(:,:,:,position),[3,2,1,4]),[N_DOE,1,1,bin_size]).*repmat(permute(C1iq_scaled_krig((IndexBegin:IndexEnd),:,:,position),[3,2,4,1]),[N_DOE,1,N_DOE,1]);
                C2ijlC1il_forSkew_1st(:,:,:,:,position,counter)=repmat(C2ijq_scaledKrig(:,:,:,position),[1,1,1,bin_size]).*repmat(permute(C1iq_scaled_krig((IndexBegin:IndexEnd),:,:,position),[4,2,3,1]),[N_DOE,1,N_DOE,1]);
                a1a2a3_1st(:,:,:,:,position,counter)=repmat(gamma',[1,1,size(gamma,2),bin_size]).*repmat(permute(gamma',[3,2,1]),[size(gamma,2),1,1,bin_size]).*repmat(permute(gamma_inv((IndexBegin:IndexEnd),:,:,:),[3,2,4,1]),[size(gamma,2),1,size(gamma,2),1]);
                prod1prod2prod3_1st(:,:,:,:,position,counter)=(prod(C3ijkl_KrigScaled_1st(:,:,:,:,position,counter),2)-3*prod(C2ijlC1il_forSkew_1st(:,:,:,:,position,counter),2)+2*prod(C1i1C1i2C1i3l_scaledSkew_1st(:,:,:,:,position,counter),2));
                Noisestruct.a1a2a3_1st(:,:,:,:,position)=a1a2a3_1st(:,:,:,:,position,counter);
                Noisestruct.prod1prod2prod3_1st(:,:,:,:,position)=prod1prod2prod3_1st(:,:,:,:,position,counter);
            else
                C3ijkl_KrigScaled_2nd(:,:,:,:,position,counter)=t1_skewKr.*exp(t2_skewKr.*(t3A_skewKr.^2+t3B_skewKr.^2+t3C_skewKr.^2+(t5_skewKr.*(t6A_skewKr.^2+t6B_skewKr.^2+t6C_skewKr.^2))));  %Eq 3.18
                C1i1C1i2C1i3l_scaledSkew_2nd(:,:,:,:,position,counter)=repmat(C1iq_scaled_krig(:,:,:,position),[1,1,N_DOE,bin_size]).*repmat(permute(C1iq_scaled_krig(:,:,:,position),[3,2,1,4]),[N_DOE,1,1,bin_size]).*repmat(permute(C1iq_scaled_krig((IndexBegin:IndexEnd),:,:,position),[3,2,4,1]),[N_DOE,1,N_DOE,1]);
                C2ijlC1il_forSkew_2nd(:,:,:,:,position,counter)=repmat(C2ijq_scaledKrig(:,:,:,position),[1,1,1,bin_size]).*repmat(permute(C1iq_scaled_krig((IndexBegin:IndexEnd),:,:,position),[4,2,3,1]),[N_DOE,1,N_DOE,1]);
                a1a2a3_2nd(:,:,:,:,position,counter)=repmat(gamma',[1,1,size(gamma,2),bin_size]).*repmat(permute(gamma',[3,2,1]),[size(gamma,2),1,1,bin_size]).*repmat(permute(gamma_inv((IndexBegin:IndexEnd),:,:,:),[3,2,4,1]),[size(gamma,2),1,size(gamma,2),1]);
                prod1prod2prod3_2nd(:,:,:,:,position,counter)=(prod(C3ijkl_KrigScaled_2nd(:,:,:,:,position,counter),2)-3*prod(C2ijlC1il_forSkew_2nd(:,:,:,:,position,counter),2)+2*prod(C1i1C1i2C1i3l_scaledSkew_2nd(:,:,:,:,position,counter),2));
                Noisestruct.a1a2a3_2nd(:,:,:,:,position,counter)=a1a2a3_2nd(:,:,:,:,position,counter);
                Noisestruct.prod1prod2prod3_2nd(:,:,:,:,position,counter)=prod1prod2prod3_2nd(:,:,:,:,position,counter);
            end
        else
            if counter==1
                a1a2a3_1st(:,:,:,:,position,counter)=Noisestruct.a1a2a3_1st(:,:,:,:,position);
                prod1prod2prod3_1st(:,:,:,:,position,counter)=Noisestruct.prod1prod2prod3_1st(:,:,:,:,position);
            else
                a1a2a3_2nd(:,:,:,:,position,counter)=Noisestruct.a1a2a3_2nd(:,:,:,:,position,counter);
                prod1prod2prod3_2nd(:,:,:,:,position,counter)=Noisestruct.prod1prod2prod3_2nd(:,:,:,:,position,counter);
            end
        end
        % Calculate H1H2H3(ij,l)
        H1i1H1i2H1i3=repmat(Bip,[1,1,N_DOE,bin_size]).*repmat(permute(Bip,[3,2,1]),[N_DOE,1,1,bin_size]).*repmat(permute(Bip((IndexBegin:IndexEnd),:,:,:),[3,2,4,1]),[N_DOE,1,N_DOE,1]);
        prod_design=prod(H1i1H1i2H1i3,2);
        %Calculate Skewness
        if counter==1
            SumSplitdirection=SumSplitdirection+sum(a1a2a3_1st(:,:,:,:,position,counter).*prod1prod2prod3_1st(:,:,:,:,position,counter).*prod_design,4);
        else
            SumSplitdirection=SumSplitdirection+sum(a1a2a3_2nd(:,:,:,:,position,counter).*prod1prod2prod3_2nd(:,:,:,:,position,counter).*prod_design,4);
        end
    end
    skew=(1/StdevY_scaled^3)*(sum(sum(SumSplitdirection)));
end
    if position==length(outID(:,1))
        Flag=1;
    end
end