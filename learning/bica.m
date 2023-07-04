function [Y,A,W,R]=bica(dataset,biasset,nunits,varargin)

pr=inputParser;
pr.addParamValue('maxiter',100,@isnumeric);
pr.addParamValue('dcremoval',false,@islogical);
pr.addParamValue('centering',true,@islogical);
pr.addParamValue('lastEig',NaN,@isnumeric);
pr.addParamValue('adjust_sign',true,@islogical);
pr.addParamValue('data_for_whitening',NaN,@isnumeric);
pr.addParamValue('orthogonal',NaN,@isnumeric);
pr.parse(varargin{:});
options=pr.Results;

[datadim,ndata]=size(dataset);

fprintf('Input dimensions: %d\n',datadim);
fprintf('Data points: %d\n',ndata);

if options.dcremoval
    fprintf('Removing DC components...\n');
    dataset=bsxfun(@minus,dataset,mean(dataset, 1));
end;

if options.centering
    dataset=bsxfun(@minus,dataset,mean(dataset,2));
end;

if isnan(options.lastEig) options.lastEig=datadim; end;
fprintf('Whitening data with selected %d dimensions...\n',options.lastEig);
dfw=options.data_for_whitening;
if isnan(dfw) dfw=dataset; end;

[E,~,D]=pca(dfw','NumComponents',options.lastEig,'Centered',options.centering);
fprintf('Eigen value max=%f min=%f\n',D(1),D(options.lastEig));

V=E*(diag(D(1:options.lastEig).^(-1/2)));
Vinv=E*(diag(D(1:options.lastEig).^(1/2)));
X=V'*dataset;
Z=biasset;

inputdim=size(X,1);

R=randn(nunits,inputdim);
R=orthogonalizerows(R);

S=randn(nunits,1);

%%%%%

% f=@(x,z)-sqrt(z+x.^2);
% g=@(x,z)-x./sqrt(z+x.^2);

% f=@(x,z)-z.*abs(x);
% g=@(x,z)-z.*sign(x);

f=@(x,z)-abs(x./z);
g=@(x,z)-sign(x)./z;

% f=@(x,z)-abs(x-z);
% g=@(x,z)-sign(x-z);

% f=@(x,z)(x>0).*-x.*(1./z)+(x<=0).*x.*z;
% g=@(x,z)(x>0).*-(1./z)+(x<=0).*z;

% f=@(x,z)(x>0).*-x.*(1./z)+(x<=0).*x;
% g=@(x,z)(x>0).*-(1./z)+(x<=0).*1;

% f=@(x,z)-abs(x)+exp(x).*z;
% g=@(x,z)-sign(x)+exp(x).*z;

% f=@(x,z)-abs(x)+x.*z;
% g=@(x,z)-sign(x)+x.*z;

% f0=@(x)-sqrt(1+x.^2);
% g0=@(x)-x./sqrt(1+x.^2);
% 
% f=@(x,z)f0(x+z)-x.*g0(z);
% g=@(x,z)g0(x+z)-g0(z);

alpha0=1e-3;

halt=false;
for T=1:options.maxiter
    Y=R*X;
%     dR=g(Y,bsxfun(@times,S,Z))*X';
    dR=g(Y,Z)*X';
    dS=sum(bsxfun(@times,Z,g(Y,bsxfun(@times,S,Z))),2);
    
    alpha=alpha0;
    L=sum(sum(f(Y,Z),2));
%     L=sum(sum(f(Y,bsxfun(@times,S,Z)),2));
    while(true)
        R1=R+alpha*dR;
        R1=orthogonalizerows(R1);
        S1=S+alpha*dS;
        Y1=R1*X;
%         L1=sum(sum(f(Y1,bsxfun(@times,S1,Z)),2));
        L1=sum(sum(f(Y1,Z),2));
        if ~isinf(L1) && L1>L Y=Y1; R=R1; S=S1; L=L1; break; end;
        alpha=alpha/2;
        if alpha<alpha0*1e-10 halt=true; break; end;
    end;
    if halt break; end;

    R=orthogonalizerows(R);

    fprintf('step #%d, log likelihood=%1.5f, alpha=%1.3g)\n',T,L,alpha);
    
end;


W=R*V';
A=Vinv*R';

if options.adjust_sign
    s=skewness(Y,0,2)>=0;
%     s=S>=0;
    W=bsxfun(@times,W,s*2-1);
    A=bsxfun(@times,A,s'*2-1);
    Y=bsxfun(@times,Y,s*2-1);
end;

end

function Wort=orthogonalizerows(W)

Wort = real((W*W')^(-0.5))*W;

end

                  