function [corr_add corr_mult]=freiwald_show_stat2(net,varargin)

pr=inputParser;
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

tuning=prop.tuning;
tuning2=prop.tuning2;

corr_mult=zeros(nparam,nparam,nunit); 
corr_add=zeros(nparam,nparam,nunit); 
% parfor U=1:nunit
for U=1:nunit
    for P1=1:nparam 
        for P2=1:nparam 
            tuning_mult=tuning(:,P1,U)*tuning(:,P2,U)';
            tuning_add=repmat(tuning(:,P1,U),1,nvalue)+repmat(tuning(:,P2,U)',nvalue,1);
            corr_mult(P1,P2,U)=corr(flatten(tuning_mult),flatten(tuning2(:,:,P1,P2,U))); 
            corr_add(P1,P2,U)=corr(flatten(tuning_add),flatten(tuning2(:,:,P1,P2,U))); 
        end;
    end; 
end;

for U=1:nunit
    for P1=1:nparam
        corr_mult(P1,P1,U)=NaN;
        corr_add(P1,P1,U)=NaN;
    end;
end;

corr_mult=corr_mult(:,:,options.face_selective);
corr_add=corr_add(:,:,options.face_selective);

figure;
h=histc([corr_add(:) corr_mult(:)],0:0.02:1);
b=bar(0:0.02:1,h/sum(h(:,1)),'edgecolor','none');
b(1).FaceColor='b';
b(2).FaceColor='r';
legend('additive predictor','multiplicative predictor');
xlabel('correlation coefficients');
ylabel('# of cases (%)');
set(gca,'FontName','Times','FontSize',12)
xlim([0 1]);
set(gca,'YTickLabel',get(gca,'YTick')*100);

p=ranksum(corr_add(:),corr_mult(:),'tail','left');
fprintf('average correlation for additive predictor: %1.7f\n',nanmean(corr_add(:)));
fprintf('average correlation for multiplicative predictor: %1.7f\n',nanmean(corr_mult(:)));
fprintf('U-test: p=%1.3e\n',p);


end



