function [Y,A,W]=mlica(dataset,nunits,varargin)

pr=inputParser;
pr.addParamValue('maxiter',100,@isnumeric);
pr.addParamValue('dcremoval',false,@islogical);
pr.addParamValue('lastEig',NaN,@isnumeric);
pr.addParamValue('sparse',true,@islogical);
pr.addParamValue('adjustsign',true,@islogical);
pr.addParamValue('data_for_whitening',NaN,@isnumeric);
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
fprintf('Whitening data with selected %d dimensions...\n', options.lastEig);
dfw=options.data_for_whitening;
if isnan(dfw) dfw=dataset; end;
[E,~,D]=pca(dfw','NumComponents',options.lastEig);
fprintf('Eigen value max=%f min=%f\n',D(1),D(options.lastEig));

V=E*(diag(D(1:options.lastEig).^(-1/2)));
Vinv=E*(diag(D(1:options.lastEig).^(1/2)));
X=V'*dataset;

inputdim=size(X,1);

R=randn(nunits,inputdim);
R=orthogonalizerows(R);

%%%%%

if options.sparse
    f=@(x)-log(cosh(x));
    g=@(x)-tanh(x);
else
    f=@(x)-1/2*x.^2+log(cosh(x));
    g=@(x)-x+tanh(x);
end;

alpha0=1e-3;

halt=false;
for T=1:options.maxiter
    Y=R*X;
    dR=g(Y)*X';

    alpha=alpha0;
    L=sum(sum(f(Y),2));
    while(true)
        R1=R+alpha*dR;
        R1=orthogonalizerows(R1);
        Y1=R1*X;
        L1=sum(sum(f(Y1),2));
        if ~isinf(L1) && L1>L Y=Y1; R=R1; L=L1; break; end;
        alpha=alpha/2;
        if alpha<alpha0*1e-10 halt=true; break; end;
    end;
    if halt break; end;

    R=orthogonalizerows(R);

    fprintf('step #%d, log likelihood=%1.5f, alpha=%1.3g)\n',T,L,alpha);
    
end;


W=R*V';
A=Vinv*R';

if options.adjustsign
    s=skewness(Y,0,2)>=0;
    if ~options.sparse s=-s; end;
    W=bsxfun(@times,W,s*2-1);
    A=bsxfun(@times,A,s'*2-1);
    Y=bsxfun(@times,Y,s*2-1);
end;

end

function Wort=orthogonalizerows(W)

Wort = real((W*W')^(-0.5))*W;

end

                  