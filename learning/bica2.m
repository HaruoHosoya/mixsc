function [Y,A,W,R]=bica2(dataset,biasset,nunits,varargin)

pr=inputParser;
pr.addParamValue('maxiter',100,@isnumeric);
pr.addParamValue('dcremoval',false,@islogical);
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

dataset=bsxfun(@minus,dataset,mean(dataset,2));

if isnan(options.lastEig) options.lastEig=datadim; end;
fprintf('Whitening data with selected %d dimensions...\n',options.lastEig);
dfw=options.data_for_whitening;
if isnan(dfw) dfw=dataset; end;

if ~isnan(options.orthogonal)
    fprintf('Subtracting %d orthogonal dimensions...\n',options.lastEig);
    [Eo,~,~]=pca(options.orthogonal','NumComponents',options.lastEig);
    dfw=dfw-Eo*(Eo'*dfw);
end;

[E,~,D]=pca(dfw','NumComponents',options.lastEig);
fprintf('Eigen value max=%f min=%f\n',D(1),D(options.lastEig));

V=E*(diag(D(1:options.lastEig).^(-1/2)));
Vinv=E*(diag(D(1:options.lastEig).^(1/2)));
X=V'*dataset;
B=biasset;

inputdim=size(X,1);

R=randn(nunits,inputdim);
R=orthogonalizerows(R);

S=randn(nunits,1);

%%%%%

% f=@(x,b)-sqrt(b+x.^2);
% g=@(x,b)-x./sqrt(b+x.^2);

% f=@(x,b)-b.*abs(x);
% g=@(x,b)-b.*sign(x);

f=@(x,s,b)-abs(bsxfun(@plus,x,s)./b);
g=@(x,s,b)-sign(bsxfun(@plus,x,s)./b)./b;

% f=@(x,b)-abs(x-b);
% g=@(x,b)-sign(x-b);

% f=@(x,b)(x>0).*-x.*(1./b)+(x<=0).*x.*b;
% g=@(x,b)(x>0).*-(1./b)+(x<=0).*b;

% f=@(x,b)(x>0).*-x.*(1./b)+(x<=0).*x;
% g=@(x,b)(x>0).*-(1./b)+(x<=0).*1;

% f=@(x,b)-abs(x)+exp(x).*b;
% g=@(x,b)-sign(x)+exp(x).*b;

% f=@(x,b)-abs(x)+x.*b;
% g=@(x,b)-sign(x)+x.*b;

% f0=@(x)-sqrt(1+x.^2);
% g0=@(x)-x./sqrt(1+x.^2);
% 
% f=@(x,b)f0(x+b)-x.*g0(b);
% g=@(x,b)g0(x+b)-g0(b);

alpha0=1e-3;

halt=false;
for T=1:options.maxiter
    Y=R*X;
    dR=g(Y,S,B)*X';
    dS=sum(g(Y,S,B),2);
    
    alpha=alpha0;
    L=sum(sum(f(Y,S,B),2));
    while(true)
        R1=R+alpha*dR;
        R1=orthogonalizerows(R1);
        S1=S+alpha*dS;
        Y1=R1*X;
        L1=sum(sum(f(Y1,S1,B),2));
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

                  