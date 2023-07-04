function net=learn_mlp(net,input,output,varargin)

pr=inputParser;
pr.addParamValue('a',1,@isnumeric);
pr.addParamValue('rho',1,@isnumeric);
pr.addParamValue('maxIter',200,@isnumeric);

pr.parse(varargin{:});
options=pr.Results;

net.rho=options.rho;
net.a=options.a;

%%

for I=2:net.nlayer
    W0{I}=rand(size(net.W{I}))*2-1;
end;

X0=compose(W0);

opts.Method='lbfgs';
opts.maxIter=options.maxIter;
[X,ll]=minFunc(@obj_aux,X0,opts);

% for gradient check only

% opts = optimset('Display','off', 'Algorithm', 'interior-point', ...
%     'TolFun', 1e-4, 'TolX', 1e-4, 'MaxFunEvals', 5000,'GradObj','on','DerivativeCheck','on');
% [X,ll]=fminunc(@obj_aux,X0,opts);

%

net.W=decompose(X);

    function [L,grad]=obj_aux(X)
        W=decompose(X);
        [L,G]=obj_multi(net,W,input,output);
        L=-L; grad=-compose(G);
    end


    function X=compose(W)
        X=[];
        for J=2:net.nlayer
            X=[X;W{J}(:)];
        end
    end

    function W=decompose(X)
        for J=2:net.nlayer
            W{J}=reshape(X(1:numel(net.W{J})),size(net.W{J}));
            X=X(numel(net.W{J})+1:end);
        end
    end
        

end


function [L,G]=obj_multi(net,W,input,output)

    datalen=size(input,2);
    indim=size(input,1);
    outdim=size(output,1);

    x{1}=input;            
    for J=2:net.nlayer
        z{J}=W{J}*x{J-1};
        [x{J},xg{J}]=nonlin(net.nonlin{J},z{J},net.a);
    end;

    d=x{net.nlayer}(1:outdim,:)-output;
    L=-1/(2*net.rho^2)*sum(sum(d.^2,1),2);

    for J=net.nlayer:-1:2
        G{J}=zeros(size(W{J}));
        if J==net.nlayer
            v{J}=-1/net.rho^2*d.*xg{net.nlayer};
        else
            v{J}=(W{J+1}'*v{J+1}).*xg{J};
        end;

        G{J}=G{J}+v{J}*x{J-1}';

    end;


end

function [f,g]=nonlin(name,x,a,epsilon)

sqrt2=sqrt(2);
sqrt2pi=sqrt(2*pi);

if ~exist('epsilon','var')
    epsilon=1e-120;
end;

switch(name)
    case 'linear'
        f=x;
        g=x.*0+1;
    case 'relu'
        f=(x<0).*epsilon.*x+(x>=0).*x;
        g=(x<0).*epsilon+(x>=0).*1;
    case 'logistic2'
        f=erfc(-x/(sqrt2*a))/2;
        g=(1/(sqrt2pi*a))*exp(-x.^2/(2*a^2));
    case 'logistic1'
        e=exp(-abs(x)/a);
        f=sign(x).*(1-e)/2+0.5;
        g=e/(2*a);
    case 'softplus'
        e=exp(x/a);
        f=a*log(1+e);
        g=e./(1+e);
    otherwise
        error(sprintf('no such nonlinear function: %s',name));
end;
 
end

    