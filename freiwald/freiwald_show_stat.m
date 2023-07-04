function [h1,h2,ramp_like_idx,tuning_sig,npeak,ntrough]=freiwald_show_stat(net,varargin)

pr=inputParser;
pr.addParamValue('conf_level',99.9,@isnumeric);
pr.addParamValue('face_selective',NaN,@isnumeric);
pr.addParamValue('tuning','full',@isstr);
pr.addParamValue('min_ntuning',10,@isnumeric);
pr.addParamValue('all_in_one',false,@islogical);
pr.addParamValue('expdata',false,@islogical);
pr.addParamValue('curve',false,@islogical);

pr.parse(varargin{:});
options=pr.Results;

nparam=19;
nvalue=11;
values=-5:5;

v2info=net.structure.layers{4};
v2=net.content.layers{4};
prop=v2.unitProperties2;
nunit=v2info.numUnits;
% resp=v2.unitProperties.resp;

switch(options.tuning)
    case 'full'
        tuning=prop.tuning;
        tuning_sig=prop.tuning_sig;
    case '1d'
        tuning=prop.tuning_single;
        tuning_sig=prop.tuning_single_sig;
    case '1d_noface'
        tuning=prop.tuning_single_noface;
        tuning_sig=prop.tuning_single_noface_sig;
end;

% baseline=prop.baseline;
% tuning_het_surr=prop.tuning_het_surr;

% tuning_sig=false(nparam,nunit);

feature_names=cartoon_feature_names;
cmap=red_blue_colormap;

% for U=1:nunit
%     for P=1:nparam
%         tuning_sig(P,U)=tuning_significance(tuning(:,P,U),tuning_het(1,P,U),tuning_het_surr(:,P,U),size(tuning_het_surr,1)*options.conf_level/100);
%     end;
% end;

if isnan(options.face_selective) options.face_selective=v2.face_selective; end;

tuning_sig=tuning_sig(:,options.face_selective);
tuning=tuning(:,:,options.face_selective);
nunit=size(tuning_sig,2);

if options.all_in_one 
    tuning=reshape(tuning,nvalue,1,nparam*nunit);
    tuning_sig=reshape(tuning_sig,1,nparam*nunit);
    nunit=nparam*nunit; nparam=1; 
    feature_names={'all tunings'};
end;

if options.expdata
    [~,exp_nfeature_per_unit]=read_expdata('expdata/nfeature_per_unit.txt');
    [exp_nunit_per_feature,~]=read_expdata('expdata/nunit_per_feature.txt');
    exp_nunit_per_feature=max(0,-exp_nunit_per_feature);
    [~,m1_npeak]=read_expdata('expdata/monkey1-peak.txt');
    [~,m2_npeak]=read_expdata('expdata/monkey2-peak.txt');
    [~,m3_npeak]=read_expdata('expdata/monkey3-peak.txt');
    [~,m1_ntrough]=read_expdata('expdata/monkey1-trough.txt');
    [~,m2_ntrough]=read_expdata('expdata/monkey2-trough.txt');
    [~,m3_ntrough]=read_expdata('expdata/monkey3-trough.txt');
    [~,min_value]=read_expdata('expdata/min_value.txt');
    min_value=max(0,min_value);
end;

h1=figure('position',[50 1000 1000 1000]);
wid=ceil(sqrt(nparam));
hit=ceil(nparam/wid);

% tuning=bsxfun(@minus,tuning,reshape(min(reshape(tuning,nvalue*nparam,nunit),[],1),1,1,nunit));
% tuning=bsxfun(@minus,tuning,reshape(baseline,1,1,nunit));
% tuning=bsxfun(@rdivide,tuning,reshape(max(reshape(tuning,nvalue*nparam,nunit),[],1),1,1,nunit));

% tuning=bsxfun(@minus,tuning,reshape(mean(reshape(tuning,nvalue*nparam,nunit),1),1,1,nunit));

ramp_like_idx=zeros(nparam,1);

% all_maxi=[];
% all_kur=[];

Q=1;
for P=1:nparam
    tun0=reshape(tuning(:,P,:),nvalue,nunit);
    units=find(tuning_sig(P,:)');
    
    if length(units)>=options.min_ntuning 
        tun=tun0(:,units);
        tun=bsxfun(@minus,tun,mean(tun,1));
    %         r=bsxfun(@minus,r,baseline(1,units));
        tun=tun/max(tun(:));
        [~,maxi]=max(tun,[],1);
        [~,idx]=sort(maxi,'ascend');
        tun=tun(:,idx);
        ramp_like_idx(P)=sum(maxi==1|maxi==11)/2/sum(maxi>1&maxi<11)*9;
%         all_maxi=[all_maxi; maxi'];
%         all_kur=[all_kur; kurtosis(resp(:,units),[],1)'-3];

        subplot(hit*2,wid,Q);
        imagesc(values(1),1,tun',[-1 1]);
        colormap(cmap);
        title(feature_names(P));
        if mod(Q,wid)==1 ylabel('tuning #'); end;
        set(gca,'XTickLabel',[]);
        set(gca,'FontName','Times','FontSize',12)

        subplot(hit*2,wid,Q+wid);
        hist(values(maxi),values);
        title(sprintf('[%1.1f]',ramp_like_idx(P)));
        xlim([values(1)-1 values(end)+1]);
        set(gca,'XTick',[values(1) 0 values(end)]);
        set(gca,'FontName','Times','FontSize',12)
        if mod(Q,wid)==1 ylabel('# of peaks'); end;
        Q=Q+1; if mod(Q-1,wid)==0 Q=Q+wid; end;
    end;    
end;

h2=figure('position',[1100 800 1200 400]);

all_resp=tuning(:,find(tuning_sig));
[~,maxi]=max(all_resp,[],1);
[~,mini]=min(all_resp,[],1);
extremity_preference_index=sum(maxi==1|maxi==11)/2/sum(maxi>1&maxi<11)*9;
extremity_disfavor_index=sum(mini==1|mini==11)/2/sum(mini>1&mini<11)*9;

subplot(2,4,3);
h=hist(values(maxi),values);
npeak=h/sum(h)*100;
bar(values,npeak,1);
if options.expdata
    hold on;
    mean_npeak=mean([m1_npeak/sum(m1_npeak) m2_npeak/sum(m2_npeak) m3_npeak/sum(m3_npeak)],2);
%     bar(values,mean_npeak*100,1,'r','facealpha',0.6);
    if options.curve plot(values,mean_npeak*100,'r');
    else bar(values,mean_npeak*100,1,'edgecolor','r','facecolor','none');
    end;
%     plot(values,m1_npeak/sum(m1_npeak)*100,'r');
%     plot(values,m2_npeak/sum(m2_npeak)*100,'r');
%     plot(values,m3_npeak/sum(m3_npeak)*100,'r');
end;
title(sprintf('all tunings [%1.1f]',extremity_preference_index));
xlim([values(1)-1 values(end)+1]);
set(gca,'XTick',[values(1) 0 values(end)]);
set(gca,'FontName','Times','FontSize',12)
ylabel('# of peaks (%)');

subplot(2,4,7);
h=hist(values(mini),values);
ntrough=h/sum(h)*100;
bar(values,ntrough,1);
xlim([values(1)-1 values(end)+1]);
title(sprintf('all tunings [%1.1f]',extremity_disfavor_index));
if options.expdata
    hold on;
    mean_ntrough=mean([m1_ntrough/sum(m1_ntrough) m2_ntrough/sum(m2_ntrough) m3_ntrough/sum(m3_ntrough)],2);
    if options.curve plot(values,mean_ntrough*100,'r');
    else bar(values,mean_ntrough*100,1,'edgecolor','r','facecolor','none');
    end;
%     plot(values,m1_ntrough/sum(m1_ntrough)*100,'r');
%     plot(values,m2_ntrough/sum(m2_ntrough)*100,'r');
%     plot(values,m3_ntrough/sum(m3_ntrough)*100,'r');
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
bar(values(1:end-1),diag(h)/sum(h)*100,1,'stack');
colormap(g);
if options.expdata
    hold on;
    if options.curve plot(values(1:end-1),min_value,'r');
    else bar(values(1:end-1),min_value,1,'edgecolor','r','facecolor','none');
    end;
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
if ~options.all_in_one 
    bar(0:max(nfeature_per_unit),h/nunit*100,1);
end
if options.expdata
    hold on;
    if options.curve plot(0:length(exp_nfeature_per_unit)-1,exp_nfeature_per_unit,'r');
    else bar(0:length(exp_nfeature_per_unit)-1,exp_nfeature_per_unit,1,'edgecolor','r','facecolor','none');
    end;
end;
xlim([-1 max(nfeature_per_unit)+1]);
% ylim([0 40]);
xlabel('# of features');
ylabel('# of units (%)');
title(sprintf('mean=%1.3f',mean(nfeature_per_unit)));
set(gca,'FontName','Times','FontSize',12)

subplot(2,4,[1 5]);
nunit_per_feature=sum(tuning_sig,2);
if ~options.all_in_one 
    barh(1:19,nunit_per_feature/nunit*100,1);
end
if options.expdata
    hold on;
    if options.curve plot(exp_nunit_per_feature,1:19,'r');
    else barh(1:19,exp_nunit_per_feature,1,'edgecolor','r','facecolor','none');
    end;
end;
set(gca,'YTick',1:19,'YTickLabel',feature_names);
xlabel('# of units (%)');
% xlim([0 100]);
axis ij;
set(gca,'xdir','r');
set(gca,'FontName','Times','FontSize',12)

% figure;
% 
% scatter(abs(all_maxi-6),all_kur);

end



