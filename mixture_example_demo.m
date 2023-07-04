function mixture_example_demo(N)

A1=[1.5 0; 0 1]*[sin(pi/4) cos(pi/4); -cos(pi/4) sin(pi/4)];
A2=[1.5 0; 0 1]*[sin(-pi/4) cos(-pi/4); -cos(-pi/4) sin(-pi/4)];

c1=[-3 0];
c2=[3 2];

x=randn(N,2);
x1=x*A1;
x2=x*A2;

figure; 

subplot(1,2,1);
scatter(x1(:,1)+c1(1),x1(:,2)+c1(2),40,'b.');
hold on;
scatter(x2(:,1)+c2(1),x2(:,2)+c2(2),40,'b.');

p=0:pi/64:2*pi;
r=[cos(p') sin(p')];
r1=r*A1*2;
r2=r*A2*2;
plot(r1(:,1)+c1(1),r1(:,2)+c1(2),'r','LineWidth',4);
plot(r2(:,1)+c2(1),r2(:,2)+c2(2),'g','LineWidth',4);

axis square; axis off;
xlim([-8 8]);
ylim([-8 8]);

%%%%

x=randlap([N,2]);
x1=x*A1;
x2=x*A2;

subplot(1,2,2);
scatter(x1(:,1)+c1(1),x1(:,2)+c1(2),40,'b.');
hold on;
scatter(x2(:,1)+c2(1),x2(:,2)+c2(2),40,'b.');

plot(r1(:,1)+c1(1),r1(:,2)+c1(2),'r','LineWidth',4);
plot(r2(:,1)+c2(1),r2(:,2)+c2(2),'g','LineWidth',4);

axis square; axis off;
xlim([-8 8]);
ylim([-8 8]);


end
