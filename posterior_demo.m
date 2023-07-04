function posterior_demo

[x,y]=meshgrid(-5:0.5:10,-5:0.5:10);
f1=exp(-(x-3).^2/1).*exp(-abs(x-2)/2).*exp(-abs(y)/2);
f2=exp(-(y-3).^2/1).*exp(-abs(y-6)/2).*exp(-abs(x)/2);
figure;mesh(x,y,f1,'EdgeColor','r')
hold on;mesh(x+0.25,y+0.25,f2,'EdgeColor','b')

end
