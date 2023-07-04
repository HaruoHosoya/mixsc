function [Y,A,W,alpha,U]=smica_biased(data,bias,nout,varargin)

pr=inputParser;
pr.addParamValue('lastEig',NaN,@isnumeric);
pr.addParamValue('maxIter',1000,@isnumeric);
pr.addParamValue('display','iter',@isstr);
pr.addParamValue('init_W',NaN,@isnumeric);
pr.addParamValue('init_alpha',NaN,@isnumeric);
pr.addParamValue('tolEig',1e-7,@isnumeric);
pr.addParamValue('fix_alpha',true,@islogical);
pr.addParamValue('centering',true,@islogical);

pr.parse(varargin{:});
opts=pr.Results;

[datadim,datalen]=size(data);
[biasdim,~]=size(bias);

fprintf('Input dimensions: %d\n',datadim);
fprintf('# of data points: %d\n',datalen);

if opts.centering
    data=bsxfun(@minus,data,mean(data,2));
end;

if isnan(opts.lastEig) nin=datadim; else nin=opts.lastEig; end;

[E,~,D]=pca(data','NumComponents',nin,'Centered',opts.centering);
if any(D(1:nin)/D(1)<opts.tolEig)
    nin=find(D(1:nin)/D(1)<opts.tolEig,1,'first')-1;
end;

fprintf('Whitening data with selected %d dimensions...\n',nin);
fprintf('Eigen value max=%f min=%f\n',D(1),D(nin));

V=E(:,1:nin)*(diag(D(1:nin).^(-1/2)));
Vi=E(:,1:nin)*(diag(D(1:nin).^(1/2)));
data=V'*data;

if isnan(opts.init_W) 
    U0=randn(nout,nin);
%     S0=randn(nout,1);
else    
    error('unsupported');
    U0=opts.init_W*Vi;
end;

if isnan(opts.init_alpha)
    logalpha0=randn(nout,1)*0.01;
else
    error('unsupported');
    logalpha0=log(opts.init_alpha);
end;

if opts.fix_alpha
%     params0=[U0(:); S0(:)];
    params0=[U0(:)];
    obj=@(params)icaobj_biased(params,data,bias,nin,nout);
else
    params0=[U0(:); logalpha0(:)];
    error('unsupported');
    obj=@(params)icaobj_alpha_biased(params,data,bias,nin,nout);
end;

opts.Method='lbfgs';

tic

% opts.GradObj='on';
% opts.DerivativeCheck='on';
% [params_opt,Jopt]=fminunc(obj,params0(:),opts);

[params_opt,Jopt]=minFunc(obj,params0(:),opts);

% [params_opt,Jopt]=gradientDescent(obj,params0(:),opts);
toc

U=reshape(params_opt(1:nout*nin),nout,nin);
% S=reshape(params_opt(nout*nin+1:nout*nin+nout),nout,1);

if opts.fix_alpha
    alpha=ones(nout,1);
else
    error('unsupported');
    alpha=exp(params_opt(nout*nin+1:end));
end;

U=bsxfun(@rdivide,U,sqrt(sum(U.^2,2)));

W=U*V';
A=Vi*U';
Y=U*data;

end

function [J,grad]=icaobj_alpha_biased(params,X,nin,nout)
    [J,grad]=icaobj_alpha(params,X,nin+nout,nout);
    grad(nout*nin+1:nout*nin+nin*nin)=0;
end

