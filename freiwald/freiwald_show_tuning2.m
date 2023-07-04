function freiwald_show_tuning2(net,unit,varargin)

pr=inputParser;
pr.addParamValue('tuning','2d',@isstr);
pr.addParamValue('unit',1,@isnumeric);


pr.parse(varargin{:});
options=pr.Results;

nparam=19;
nvalue=11;
values=-5:5;

v2info=net.structure.layers{4};
v2=net.content.layers{4};
prop=v2.unitProperties2;
nunit=v2info.numUnits;

baseline=prop.baseline;
tuning=prop.tuning;
tuning2=prop.tuning2;

feature_names=cartoon_feature_names;
cmap=red_blue_colormap;

switch(options.tuning)
    case '2d'
        tuning2=prop.tuning2;
    case 'mult'
        for U=1:nunit
            for P1=1:nparam 
                for P2=1:nparam 
                    tuning2=tuning(:,P1,U)*tuning(:,P2,U)';
                end;
            end;
        end;
    case 'add'
        for U=1:nunit
            for P1=1:nparam 
                for P2=1:nparam 
                    tuning2=repmat(tuning(:,P1,U),1,nvalue)+repmat(tuning(:,P2,U)',nvalue,1);
                end;
            end;
        end;
end;

tuning2=tuning2-mean(flatten(tuning2(:,:,:,:,unit)));

for P=1:nparam
    tuning2(:,:,P,P,unit)=0;
end;

mxa=max(flatten(tuning2(:,:,:,:,unit)));

mx=max(flatten(tuning(:,:,unit)));
mn=min(flatten(tuning(:,:,unit)));

figure;Q=2;
for P=1:nparam
    subplot(nparam+1,nparam+1,Q);Q=Q+1;
    plot(-5:5,tuning(:,P,unit));    
    xlim([-5 5]); 
    ylim([mn mx]);
    axis square;
    set(gca,'XTick',[]);
    if P~=nparam set(gca,'YTick',[]); end;
    set(gca,'YAxisLocation','right'); 
end;

for P1=1:nparam
    subplot(nparam+1,nparam+1,Q);Q=Q+1;
    plot(tuning(:,P1,unit),-5:5);
    ylim([-5 5]);
    xlim([mn mx]);
    axis square;
    set(gca,'YTick',[]);
    if P1~=nparam set(gca,'XTick',[]); end;
    axis ij; 
    for P2=1:nparam 
        if P1==P2 Q=Q+1; continue; end;
        subplot(nparam+1,nparam+1,Q);Q=Q+1;
        imagesc(values(1),values(1),tuning2(:,:,P1,P2,unit),[-mxa mxa]); 
        colormap(cmap);
        axis square;
        if P2~=nparam set(gca,'YTick',[]); end;
        set(gca,'YAxisLocation','right');
        if P1~=nparam set(gca,'XTick',[]); end;
    end; 
end;


end



