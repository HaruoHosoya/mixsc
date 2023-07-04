function freiwald_show_stat_multi(tuning_sig,npeak,ntrough,cs)

nparam=19;
nvalue=11;
values=-5:5;

feature_names=cartoon_feature_names;

figure('position',[50 1000 1000 1000]);

% cs={'b','r','g','m','y','c'};
% ws={1,0.9,0.8,0.7,0.6};

% ei=@(a)(a(1)+a(11))/2/(sum(a(2:10)))*9;

[~,exp_nfeature_per_unit]=read_expdata('expdata/nfeature_per_unit.txt');
[exp_nunit_per_feature,~]=read_expdata('expdata/nunit_per_feature.txt');
exp_nunit_per_feature=max(0,-exp_nunit_per_feature);
[~,m1_npeak]=read_expdata('expdata/monkey1-peak.txt');
[~,m2_npeak]=read_expdata('expdata/monkey2-peak.txt');
[~,m3_npeak]=read_expdata('expdata/monkey3-peak.txt');
[~,m1_ntrough]=read_expdata('expdata/monkey1-trough.txt');
[~,m2_ntrough]=read_expdata('expdata/monkey2-trough.txt');
[~,m3_ntrough]=read_expdata('expdata/monkey3-trough.txt');

subplot(2,3,[1 4]);
for I=1:length(tuning_sig)
    nunit_per_feature=sum(tuning_sig{I},2);
%     barh(1:19,nunit_per_feature/nunit*100,ws{I},'facecolor','none','edgecolor',cs{I});
%     nunit_per_feature=[0; nunit_per_feature; 0];
%     stairs(nunit_per_feature/size(tuning_sig{I},2)*100,0.05*I+0.5+(0:20),cs{I});
    plot(nunit_per_feature/size(tuning_sig{I},2)*100,(1:19),'color',cs{I});
    hold on;
end;
% plot(exp_nunit_per_feature,1:19,'r');
set(gca,'YTick',1:19,'YTickLabel',feature_names);
xlabel('# of units (%)');
ylim([0.5 19.5]);
% xlim([0 100]);
axis ij;
set(gca,'xdir','r');
set(gca,'FontName','Times','FontSize',12)

subplot(2,3,[2 5]);
for I=1:length(tuning_sig)
    nfeature_per_unit=sum(tuning_sig{I},1);
%     bar(I,mean(nfeature_per_unit),'facecolor','none','edgecolor',cs{I});
    h=hist(nfeature_per_unit,0:max(nfeature_per_unit));
%     h=[0 h 0];
%     stairs(0.1*I-0.5+(-1:max(nfeature_per_unit)+1),h/size(tuning_sig{I},2)*100,cs{I});
    plot((0:max(nfeature_per_unit)),h/size(tuning_sig{I},2)*100,'color',cs{I});
    hold on;
end;
xlim([-0.5 13]);
% plot(0:length(exp_nfeature_per_unit)-1,exp_nfeature_per_unit,'r');
xlabel('# of features');
ylabel('# of units (%)');
set(gca,'FontName','Times','FontSize',12)

subplot(2,3,[3]);
for I=1:length(npeak)
%     bar(I,ei(npeak{I}),'facecolor','none','edgecolor',cs{I});
%     stairs(0.1*I-0.5+[-6 values 6],[0 npeak{I} 0],cs{I});
    plot(values,npeak{I},'color',cs{I});
    hold on;
end;
xlim([-5.5 5.5]);
% bar(ncase+1,ei(m1_npeak));
% bar(ncase+2,ei(m2_npeak));
% bar(ncase+3,ei(m3_npeak));
ylabel('# of peaks (%)');
set(gca,'FontName','Times','FontSize',12)

subplot(2,3,[6]);
for I=1:length(ntrough)
%    bar(I,ei(ntrough{I}),'facecolor','none','edgecolor',cs{I});
%     stairs(0.1*I-0.5+[-6 values 6],[0 ntrough{I} 0],cs{I});
    plot(values,ntrough{I},'color',cs{I});
    hold on;
end;
xlim([-5.5 5.5]);
% bar(ncase+1,ei(m1_ntrough));
% bar(ncase+2,ei(m2_ntrough));
% bar(ncase+3,ei(m3_ntrough));
ylabel('# of troughs (%)');
xlabel('parameter value');
set(gca,'FontName','Times','FontSize',12)



return;


subplot(2,4,3);
h=hist(values(maxi),values);
npeak=h/sum(h)*100;
bar(values,npeak);
if options.expdata
    hold on;
    plot(values,m1_npeak/sum(m1_npeak)*100,'r');
    plot(values,m2_npeak/sum(m2_npeak)*100,'r');
    plot(values,m3_npeak/sum(m3_npeak)*100,'r');
end;
title(sprintf('all tunings [%1.1f]',extremity_preference_index));
xlim([values(1)-1 values(end)+1]);
set(gca,'XTick',[values(1) 0 values(end)]);
set(gca,'FontName','Times','FontSize',12)
ylabel('# of peaks (%)');

subplot(2,4,7);
h=hist(values(mini),values);
ntrough=h/sum(h)*100;
bar(values,ntrough);
xlim([values(1)-1 values(end)+1]);
title(sprintf('all tunings [%1.1f]',extremity_disfavor_index));
if options.expdata
    hold on;
    plot(values,m1_ntrough/sum(m1_ntrough)*100,'r');
    plot(values,m2_ntrough/sum(m2_ntrough)*100,'r');
    plot(values,m3_ntrough/sum(m3_ntrough)*100,'r');
end;
ylabel('# of troughs (%)');
xlabel('parameter value');
set(gca,'XTick',[values(1) 0 values(end)]);
set(gca,'FontName','Times','FontSize',12)
axis ij;

tun=[all_resp(:,maxi==11) all_resp(end:-1:1,maxi==1)];
[~,mini]=min(tun,[],1);
mresp=zeros(nvalue,nvalue);
for I=1:nvalue
    mresp(:,I)=mean(tun(:,mini==I),2);
    mresp(:,I)=mresp(:,I)-min(mresp(:,I));
    mresp(:,I)=mresp(:,I)/max(mresp(:,I));
end;

subplot(2,4,4); 
g=[linspace(0,1,11)' linspace(0,1,11)' linspace(0.5,1,11)'];
h=hist(values(mini),values(1:end-1));
bar(values(1:end-1),diag(h)/sum(h)*100,'stack');
colormap(g);
if options.expdata
    hold on;
    plot(values(1:end-1),min_value,'r');
end;
xlim([values(1)-1 values(end-1)+1]);
title('minimal values');
set(gca,'XTick',[values(1) 0 values(end-1)]);
set(gca,'FontName','Times','FontSize',12)
ylabel('# of tunings (%)');
xlabel('parameter value');

subplot(2,4,8); hold on; 
for I=1:nvalue
    plot(values,mresp(:,I),'color',g(I,:));
end;
set(gca,'XTick',[values(1) 0 values(end)]);
set(gca,'FontName','Times','FontSize',12)
ylabel('mean normalized response');
xlabel('parameter value');

subplot(2,4,[2 6]);
nfeature_per_unit=sum(tuning_sig,1);
h=hist(nfeature_per_unit,0:max(nfeature_per_unit));
bar(0:max(nfeature_per_unit),h/nunit*100);
if options.expdata
    hold on;
    plot(0:length(exp_nfeature_per_unit)-1,exp_nfeature_per_unit,'r');
end;
xlim([-1 max(nfeature_per_unit)+1]);
% ylim([0 40]);
xlabel('# of features');
ylabel('# of units (%)');
title(sprintf('mean=%1.3f',mean(nfeature_per_unit)));
set(gca,'FontName','Times','FontSize',12)


% figure;
% 
% scatter(abs(all_maxi-6),all_kur);

end



