function freiwald_show_tuning(net,units,varargin)

pr=inputParser;
pr.addParamValue('conf_level',99.9,@isnumeric);
pr.addParamValue('tuning','full',@isstr);

pr.parse(varargin{:});
options=pr.Results;

nparam=19;
nvalue=11;
values=-5:5;

v2info=net.structure.layers{4};
v2=net.content.layers{4};
prop=v2.unitProperties2;
nunit=v2info.numUnits;

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
tuning_het_sp=prop.tuning_het_sp;
% tuning_het_surr=prop.tuning_het_surr;

% tuning_sig=false(nparam,nunit);

feature_names=cartoon_feature_names;

% for U=1:nunit
%     for P=1:nparam
%         tuning_sig(P,U)=tuning_significance(tuning(:,P,U),tuning_het(1,P,U),tuning_het_surr(:,P,U),size(tuning_het_surr,1)*options.conf_level/100);
%     end;
% end;

figure('position',[100 100 2000 1200]);
I=1;
for U=units(:)'
    mx=max([flatten(tuning(:,:,U));flatten(tuning_het_sp(:,:,:,U))]);
    mn=min([flatten(tuning(:,:,U));flatten(tuning_het_sp(:,:,:,U))]);
    for P=1:nparam
        subplot(length(units),nparam,I); I=I+1;
        plot(values,tuning(:,P,U),'r');
        hold on;
        plot(values,tuning_het_sp(:,3,P,U),'b');
        hold on;
        plot(values,tuning_het_sp(:,1,P,U),'g');
        hold on;
        plot(values,tuning_het_sp(:,2,P,U),'g');
        hold on;
%         plot([values(1) values(end)],[baseline(1,U),baseline(1,U)],'k');
        xlim([values(1) values(end)]);
%         ylim([mn-0.05 mx+0.05]);
        ylim([0 mx*1.2]);
%         fprintf('fano factor=%1.3f\n',(mean(tuning_het_sp(:,2,P,U),1)-mean(tuning_het_sp(:,1,P,U),1))/2/mean(tuning_het_sp(:,3,P,U),1));
        if U==units(1) title(feature_names{P},'FontSize',9); end;
        if U~=units(end) set(gca,'XTickLabel',[]); end;
        if P==1 ylabel(sprintf('#%d',U),'FontSize',9); 
        else set(gca,'YTickLabel',[]); end;
        if tuning_sig(P,U) text(0,mx*1.1,'*','Color','k'); end;
        set(gca,'FontName','Times','FontSize',12)
    end;
end;


end
