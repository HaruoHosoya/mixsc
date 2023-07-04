function [h1,h2]=face_selectivity(net,fdata,odata,varargin)

pr=inputParser;
pr.addParamValue('face_selective',NaN,@isnumeric);
pr.addParamValue('linear',false,@islogical);
pr.addParamValue('mode','mix',@isstr);
pr.addParamValue('ignore_signal_sd',false,@islogical);
pr.addParamValue('sort',true,@islogical);

pr.parse(varargin{:});
options=pr.Results;

if options.linear
    nonlin=@(x)x;
else
%     nonlin=@(x)max(x,0);
    nonlin=@smooth_half_rect;
end;

netf=run_face_area_model3(net,fdata,'mode',options.mode,'ignore_signal_sd',options.ignore_signal_sd);
fresp=nonlin(netf.content.layers{4}.unitProperties.resp);

neto=run_face_area_model3(net,odata,'mode',options.mode,'ignore_signal_sd',options.ignore_signal_sd);
oresp=nonlin(neto.content.layers{4}.unitProperties.resp);

netb=run_face_area_model3(net,zeros(4096,1),'mode',options.mode,'ignore_signal_sd',options.ignore_signal_sd);
baseline=nonlin(netb.content.layers{4}.unitProperties.resp);


nunits=net.structure.layers{4}.numUnits;
flen=size(fresp,1);
olen=size(oresp,1);

face_selectivity=zeros(nunits,1);
face_selectivity_p=zeros(nunits,1);
face_selectivity_index=zeros(nunits,1);
for I=1:nunits
    [face_selectivity(I),face_selectivity_p(I)]=ttest2(fresp(:,I),oresp(:,I),'Alpha',0.05,'Tail','right');
    face_selectivity_index(I)=(mean(fresp(:,I))-mean(oresp(:,I)))/(mean(fresp(:,I))+mean(oresp(:,I)));
end;


if isnan(options.face_selective)
    face_selective=net.content.layers{4}.face_selective(:);
    non_face_selective=setdiff((1:nunits)',face_selective);        
else
    face_selective=options.face_selective(:);
    non_face_selective=setdiff((1:nunits)',face_selective);
end;

n_fs=length(face_selective);
n_nfs=length(non_face_selective);


nfaces=size(fresp,1);
nobjs=size(oresp,1);

h1=figure;
subplot(3,1,1);
plot(1:n_fs,mean(fresp(:,[face_selective])),'b');
hold on;
plot(1:n_fs,mean(oresp(:,[face_selective])),'r');
plot(n_fs+1:n_fs+n_nfs,mean(fresp(:,[non_face_selective])),'b-.');
plot(n_fs+1:n_fs+n_nfs,mean(oresp(:,[non_face_selective])),'r-.');
% plot(1:nunits,baseline);
xlabel('face units (left), object units (right)');
ylabel('image-averaged response');
% legend('face images','object images');
xlim([1 nunits]); ylim(ylim);
hold on;
plot([length(face_selective);length(face_selective)],ylim,'k-');
set(gca,'FontName','Times','FontSize',12)

fi=round(linspace(1,nfaces,100)); oi=round(linspace(1,nobjs,100));
subplot(3,1,2);
plot(1:100,mean(fresp(fi,face_selective),2),'b');
hold on;
plot(1:100,mean(fresp(fi,non_face_selective),2),'b-.');
plot(101:200,mean(oresp(oi,face_selective),2),'r');
plot(101:200,mean(oresp(oi,non_face_selective),2),'r-.');
xlabel('face images (left), objects (right)');
ylabel('unit-averaged response');
% legend('face units','object units');
xlim([1 200]); ylim(ylim);
hold on;
plot([100;100],ylim,'k-');
set(gca,'FontName','Times','FontSize',12)

if isequal(options.mode,'mix')
    subplot(3,1,3);
    prob_face=netf.content.layers{4}.unitProperties.prob_face;
    plot(1:100,prob_face(fi),'b');         
    hold on;
    prob_face=neto.content.layers{4}.unitProperties.prob_face;        
    plot(101:200,prob_face(oi),'b');         
    xlabel('face images (left), objects (right)');
    ylabel('probability for face');
    xlim([1 200]);         
    ylim([0 1]);
    hold on;
    plot([100;100],ylim,'k-');
    set(gca,'FontName','Times','FontSize',12)
end;

m=max([fresp(:); oresp(:)]);
m=2;

last_face_selective=max(face_selective);

h2=figure;
subplot(1,3,1);
if options.sort fresp=sort(fresp,1,'ascend'); end;
imagesc(fresp',[0 m]);
hold on; plot(xlim,[last_face_selective;last_face_selective],'k-');
title('Faces');
ylabel('object units (up), face units (down)');
% colorbar;
set(gca,'FontName','Times','FontSize',12)

subplot(1,3,2);
if options.sort oresp=sort(oresp,1,'ascend'); end;
imagesc(oresp',[0 m]);
hold on; plot(xlim,[last_face_selective;last_face_selective],'k-');
title('Objects');
xlabel('images');
%     colorbar;
set(gca,'FontName','Times','FontSize',12)

subplot(1,3,3);
imagesc(0,[0 m]);
colorbar; axis off;
set(gca,'FontName','Times','FontSize',12)


end


