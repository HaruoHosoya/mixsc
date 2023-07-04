function [J,grad]=icaobj_biased(params,X,b,nin,nout)

W0=reshape(params(1:nout*nin),nout,nin);
% S=reshape(params(nout*nin+1:nout*nin+nout),nout,1);

Wnorm=sqrt(sum(W0.^2,2));
W=bsxfun(@rdivide,W0,Wnorm);

% [Y,Y1,Y2]=g(bsxfun(@plus,W*X,S),b);
[Y,Y1,Y2]=g(W*X,b);

Z=W'*Y;
U=W*Z;

% J=2*sum(sum(Y1))+sum(sum(Z.^2)+sum(Y.^2))/2;
% 
% gradW=2*Y2*X'+Y*Z'+Y1.*U*X'+Y1.*Y*X';

J=sum(sum(Y1))+sum(sum(Z.^2))/2;

gradW=Y2*X'+Y*Z'+Y1.*U*X';
gradS=sum(Y2+Y1.*U,2);

gradW=bsxfun(@rdivide,gradW,Wnorm)-bsxfun(@times,W,sum(W.*gradW,2)./Wnorm);

% grad=[gradW(:);gradS(:)];
grad=[gradW(:)];

end

function [y,y1,y2]=g(x,b)

% c=1;
c=0.1;

[G,y,y1,y2]=g0(x./b,c);
y=y./b;
y1=y1./(b.^2);
y2=y2./(b.^3);

% [G,y,y1,y2]=g0(x-b,c);

% [Gp,yp,yp1,yp2]=g0(1./b.*x,c);
% [Gn,yn,yn1,yn2]=g0(b.*x,c);

% G=(x<=0).*Gn+(x>0).*Gp;
% y=(x<=0).*yn.*b+(x>0).*yp./b;
% y1=(x<=0).*yn1.*(b.^2)+(x>0).*yp1./(b.^2);
% y2=(x<=0).*yn2.*(b.^3)+(x>0).*yp2./(b.^3);

% [G,y,y1,y2]=g0(x,c);
% [~,y0,~,~]=g0(0,c);
% 
% G=G-b.*(G-x+y0);
% y=y-b.*(y-1);
% y1=y1-b.*y1;
% y2=y2-b.*y2;

end

function [G,y,y1,y2]=g0(x,c)

G=-sqrt(c+x.^2);
y=x./G;
y1=c./(G.^3);
y2=-3*c*x./(G.^5);

end



% f=@(x,z)(x>0).*-x.*(1./z)+(x<=0).*x.*z;
% g=@(x,z)(x>0).*-(1./z)+(x<=0).*z;
