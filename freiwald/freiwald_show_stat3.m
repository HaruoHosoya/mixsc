function [h1,h2]=freiwald_show_stat3(net,varargin)

pr=inputParser;
pr.addParamValue('conf_level',99.9,@isnumeric);
pr.addParamValue('face_selective',NaN,@isnumeric);

pr.parse(varargin{:});
options=pr.Results;

nparam=19;
nvalue=11;
values=-5:5;

v2info=net.structure.layers{4};
v2=net.content.layers{4};
prop=v2.unitProperties2;
nunit=v2info.numUnits;

if isnan(options.face_selective) options.face_selective=v2.face_selective; end;

baseline=shiftdim(prop.baseline,-1);

tuning=prop.tuning;
tuning_het=prop.tuning_het;
% tuning_het_surr=prop.tuning_het_surr;
tuning_sig=prop.tuning_sig;

% tuning=bsxfun(@minus,tuning,baseline);

tuning_single=prop.tuning_single;
tuning_single_het=prop.tuning_single_het;
tuning_single_sig=prop.tuning_single_sig;
tuning_single_noface=prop.tuning_single_noface;
tuning_single_noface_het=prop.tuning_single_noface_het;
tuning_single_noface_sig=prop.tuning_single_noface_sig;

% tuning_single=bsxfun(@minus,tuning_single,baseline);
% tuning_single_noface=bsxfun(@minus,tuning_single_noface,baseline);

% tuning_sig=false(nparam,nunit);
% tuning_single_sig=false(nparam,nunit);
% tuning_single_noface_sig=false(nparam,nunit);
most_sig=false(nparam,nunit);
all_sig=false(nparam,nunit);

feature_names=cartoon_feature_names;
cmap=red_blue_colormap;

for U=1:nunit
%     for P=1:nparam
%         tuning_sig(P,U)=tuning_significance(tuning(:,P,U),tuning_het(1,P,U),tuning_het_surr(:,P,U),size(tuning_het_surr,1)*options.conf_level/100);
%         tuning_single_sig(P,U)=tuning_significance(tuning_single(:,P,U),tuning_single_het(1,P,U),tuning_het_surr(:,P,U),size(tuning_het_surr,1)*options.conf_level/100);
%         tuning_single_noface_sig(P,U)=tuning_significance(tuning_single_noface(:,P,U),tuning_single_noface_het(1,P,U),tuning_het_surr(:,P,U),size(tuning_het_surr,1)*options.conf_level/100);
%     end;
    if any(~tuning_sig(:,U)) && ismember(U,options.face_selective)
        [~,idx]=max(tuning_het(1,:,U)' .* tuning_sig(:,U));
        most_sig(idx,U)=true;
        all_sig(idx,U)=most_sig(idx,U) & tuning_single_sig(idx,U) & tuning_single_noface_sig(idx,U);
    end;
end;

h1=figure;

sig_tuning=tuning(:,all_sig);
sig_tuning_single=tuning_single(:,all_sig);
sig_tuning_single_noface=tuning_single_noface(:,all_sig);
mx=max([sig_tuning; sig_tuning_single; sig_tuning_single_noface],[],1);
sig_tuning=bsxfun(@rdivide,sig_tuning,mx);
sig_tuning_single=bsxfun(@rdivide,sig_tuning_single,mx);
sig_tuning_single_noface=bsxfun(@rdivide,sig_tuning_single_noface,mx);

subplot(3,1,1);
imagesc(1,values(1),sig_tuning,[0 1]);
% xlabel('cell number');
set(gca,'XTickLabel',[]);
ylabel('feature value');
title('full variation');
set(gca,'FontName','Times','FontSize',12)

subplot(3,1,2);
imagesc(1,values(1),sig_tuning_single,[0 1]);
% xlabel('cell number');
set(gca,'XTickLabel',[]);
ylabel('feature value');
title('single variation');
set(gca,'FontName','Times','FontSize',12)

subplot(3,1,3);
imagesc(1,values(1),sig_tuning_single_noface,[0 1]);
xlabel('cell number');
ylabel('feature value');
title('partial face');
set(gca,'FontName','Times','FontSize',12)

corr_full_single=zeros(nunit,1)*NaN;
corr_full_single_p=zeros(nunit,1)*NaN;
corr_single_single_noface=zeros(nunit,1)*NaN;
corr_single_single_noface_p=zeros(nunit,1)*NaN;
corr_full_single_noface=zeros(nunit,1)*NaN;
corr_full_single_noface_p=zeros(nunit,1)*NaN;

gain_ratio_full_single=zeros(nunit,1)*NaN;
gain_ratio_full_single_noface=zeros(nunit,1)*NaN;
gain_ratio_single_single_noface=zeros(nunit,1)*NaN;

fi=@(x)log(exp(x)-1);
f=@(x)log(exp(x)+1);
tuning=f(fi(tuning));
tuning_single=f(fi(tuning_single));
tuning_single_noface=f(fi(tuning_single_noface));

for U=1:nunit
    if ~any(all_sig(:,U)) continue; end;
    tuning1=tuning(:,all_sig(:,U),U);
    tuning_single1=tuning_single(:,all_sig(:,U),U);
    tuning_single_noface1=tuning_single_noface(:,all_sig(:,U),U);
    [corr_full_single(U),corr_full_single_p(U)]=corr(tuning1,tuning_single1);
    [corr_single_single_noface(U),corr_single_single_noface_p(U)]=corr(tuning_single1,tuning_single_noface1);
    [corr_full_single_noface(U),corr_full_single_noface_p(U)]=corr(tuning1,tuning_single_noface1);
    p=polyfit(tuning_single1,tuning1,1); 
    gain_ratio_full_single(U)=p(1);
    p=polyfit(tuning_single_noface1,tuning1,1); 
    gain_ratio_full_single_noface(U)=p(1);
    p=polyfit(tuning_single_noface1,tuning_single1,1); 
    gain_ratio_single_single_noface(U)=p(1);
end;

h2=figure;
mx=max([tuning(:); tuning_single(:); tuning_single_noface(:)]);
subplot(1,3,1);
line([0 mx],[0 mx],'Color','k'); hold on;
for U=1:nunit
    if ~any(all_sig(:,U)) continue; end;
    if corr_full_single(U)>0 c='r'; else c='k'; end;
%     if corr_full_single(U)>0 c='r.'; else c='k.'; end;
    plot(tuning_single(:,all_sig(:,U),U),tuning(:,all_sig(:,U),U),c);
    hold on;
end;
axis square;
% xlim([0 mx]);
% ylim([0 mx]);
ylabel('full variation');
xlabel('single variation');
set(gca,'FontName','Times','FontSize',12)

subplot(1,3,2);
line([0 mx],[0 mx],'Color','k'); hold on;
for U=1:nunit
    if ~any(all_sig(:,U)) continue; end;
    if corr_single_single_noface(U)>0 c='r'; else c='k'; end;
%     if corr_single_single_noface(U)>0 c='r.'; else c='k.'; end;
    plot(tuning_single_noface(:,all_sig(:,U),U),tuning(:,all_sig(:,U),U),c);
    hold on;
end;
axis square;
% xlim([0 mx]);
% ylim([0 mx]);
set(gca,'YTickLabel',[]);
ylabel('full variation');
xlabel('partial face');
set(gca,'FontName','Times','FontSize',12)

subplot(1,3,3);
line([0 mx],[0 mx],'Color','k'); hold on;
for U=1:nunit
    if ~any(all_sig(:,U)) continue; end;
    if corr_full_single_noface(U)>0 c='r'; else c='k'; end;
%     if corr_full_single_noface(U)>0 c='r.'; else c='k.'; end;
    plot(tuning_single_noface(:,all_sig(:,U),U),tuning_single(:,all_sig(:,U),U),c);
    hold on;
end;
axis square;
% xlim([0 mx]);
% ylim([0 mx]);
set(gca,'YTickLabel',[]);
ylabel('single variation');
xlabel('partial face');
set(gca,'FontName','Times','FontSize',12)

fprintf('average correlations:\n');
fprintf(' full-all vs full-one --> %1.3f (p<%1.3f)\n',nanmean(corr_full_single),nanmax(corr_full_single_p));
fprintf(' full-all vs partial  --> %1.3f (p<%1.3f)\n',nanmean(corr_full_single_noface),nanmax(corr_full_single_noface_p));
fprintf(' full-one vs partial  --> %1.3f (p<%1.3f)\n',nanmean(corr_single_single_noface),nanmax(corr_single_single_noface_p));

fprintf('average gains:\n');
fprintf(' full-all vs full-one --> %1.3f\n',nanmean(gain_ratio_full_single));
fprintf(' full-all vs partial  --> %1.3f\n',nanmean(gain_ratio_full_single_noface));
fprintf(' full-one vs partial  --> %1.3f\n',nanmean(gain_ratio_single_single_noface));


end



