function [Y,L,ys,ls]=sparse_coding_map_infer(R,data,Y0,options)

    % sparsity constraint

%     f=@(x)-abs(x);
%     fd=@(x)-sign(x);
    f=@(x)-sqrt(0.1+x.^2);
%     fd=@(x)-x./sqrt(0.1+bsxfun(@minus,x,b).^2);
    fd=@(x)-x./sqrt(0.1+x.^2);

    eta_init=0.05;

    ys=zeros(size(R,2),options.maxIterIn,size(data,2));
    ls=zeros(size(data,2),options.maxIterIn);

%     Y=Y0;
    Y=randn(size(R,2),size(data,2))*0.0001;
    eta=eta_init;
    l=-Inf;

    Rdata=R'*data;
    RtR=R'*R;

    for S=1:options.maxIterIn
%         fprintf('%d ',S);
        dY=(Rdata-RtR*Y)/options.rho+fd(Y)/options.lambda;

%         Y=Y+eta*dY;
%         U=data-R*Y; 
%         l=-sum(U.^2,1)/2/options.rho+sum(f(Y),1)/options.lambda;
        
        for J=1:10
            Y1=Y+eta*dY;
            U1=data-R*Y1; 
            ll=-sum(U1.^2,1)/2/options.rho+sum(f(Y1),1)/options.lambda;
            l1=sum(ll);
            if l1>l Y=Y1; l=l1; break; end;
            eta=eta/2;
            if eta<eta_init*1e-10 break; end;
        end;

        ys(:,S,:)=Y;
        ls(:,S)=ll';
        if eta<eta_init*1e-10 break; end;
    end;

    L=ll;
end
 