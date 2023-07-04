function net=freiwald_analyze_responses2(net,cdatap,cmasksp,units,varargin)

pr=inputParser;
pr.addParamValue('mode','mix',@isstr);
pr.parse(varargin{:});
options=pr.Results;

v2info=net.structure.layers{4};
nunit=v2info.numUnits;
nonlin=@smooth_half_rect;

% responses to cartoon face stimuli

net=run_face_area_model3(net,cdatap,'mode',options.mode);
resp=net.content.layers{4}.unitProperties.resp;
resp=nonlin(resp);

% analysis

[npart,len]=size(cmasksp);
c=cell(npart,1);

for I=1:npart
    c{I}=cmasksp(I,:);
end;

th=0.005;

n_sig_parts=zeros(nunit,1);

resp0=zeros(len/2,npart,nunit);
resp1=zeros(len/2,npart,nunit);

for I=1:nunit
    for J=1:npart
        resp0(:,J,I)=resp(~cmasksp(J,:),I);
        resp1(:,J,I)=resp(cmasksp(J,:),I);
    end;
    [~,p]=ttest2(resp0(:,:,I),resp1(:,:,I));
    n_sig_parts(I)=sum(p<th);
end;
        

if ~isempty(units)
    h=figure;
    n=length(units);
    for I=1:n
        ha=subplot(1,n,I);
        r=zeros(npart,2);
        s=zeros(npart,2);
        p=zeros(npart,1);
        r(:,1)=mean(resp1(:,:,I));
        r(:,2)=mean(resp0(:,:,I));
        s(:,1)=std(resp1(:,:,I));
        s(:,2)=std(resp0(:,:,I));
        [~,p]=ttest2(resp0(:,:,I),resp1(:,:,I));
        barwitherr(s,r);
        title(sprintf('cell #%d',units(I)));
        for J=1:npart
            yl=ylim;
            if p(J)<th text(J,yl(2)*0.9,'*'); end;
        end;
        n_sig_parts(I)=sum(p<th);
    end;
end;

n_sig_parts_anova=zeros(nunit,1);
n_sig_ints_anova=zeros(nunit,1);

expvar1=zeros(nunit,1);
expvar2=zeros(nunit,1);
expvar_ratio=0.9;
n_inf_parts=zeros(nunit,1);
n_inf_ints=zeros(nunit,1);

for I=1:nunit
    [p,tbl,stats,terms]=anovan(resp(:,I),c,'model','interaction','alpha',th,'display','off');
    n_sig_parts_anova(I)=sum(p(1:npart)<th);
    n_sig_ints_anova(I)=sum(p(npart+1:end)<th);
    ss=cell2mat(tbl(2:end-2,2)); 
    ss1=ss(1:npart); ss2=ss(npart+1:end);
    p1=p(1:npart); p2=p(npart+1:end);
    total_ss=cell2mat(tbl(end,2));
    expvar1(I)=sum(ss1(p1<th))/total_ss;
    expvar2(I)=sum(ss2(p2<th))/total_ss;
    
    ss1=sort(ss1,'descend'); ss2=sort(ss2,'descend');
    n_inf_parts(I)=sum(cumsum(ss1)<expvar_ratio*sum(ss1(p1<th)) & p1<th);
    n_inf_ints(I)=sum(cumsum(ss2)<expvar_ratio*sum(ss2(p2<th)) & p2<th);
end;

figure;
subplot(4,2,1);
histogram(n_sig_parts);
xlabel('# of significant parts (t-test)');

subplot(4,2,3);
histogram(n_sig_parts_anova);
xlabel('# of significant parts (ANOVA)');

subplot(4,2,4);
histogram(n_sig_ints_anova);
xlabel('# of significant part interactions (ANOVA)');

subplot(4,2,5);
histogram(expvar1);
xlabel('exp. var. by 1st-order effect');
title(sprintf('mean=%1.3f',mean(expvar1)));

subplot(4,2,6);
histogram(expvar2);
xlabel('exp. var. by 2nd-order effect');
title(sprintf('mean=%1.3f',mean(expvar2)));

subplot(4,2,7);
histogram(n_inf_parts);
xlabel('# of parts explaining 90% of 1st-order effect var.');

subplot(4,2,8);
histogram(n_inf_ints);
xlabel('# of interactions explaining 90% of 2nd-order effect var.');


end
