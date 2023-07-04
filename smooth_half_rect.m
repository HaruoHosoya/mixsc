function y=smooth_half_rect(x)

a=1;
% a=0.5; 
% a=0.3; 
% a=0.1;
d=1/a;
y=a*log(exp(x*d)+1);

end