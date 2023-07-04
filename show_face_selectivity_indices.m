function [h1,h2]=show_face_selectivity_indices(nets,modes,ndata,odata)

face_colors={'blue','yellow','magenta'};

h1=figure('position',[0 0 400 200]);
h2=figure('position',[400 0 400 200]);
for I=1:length(nets)
    net=nets{I}; m=modes{I};
    fs=net.content.layers{4}.face_selective;
    netf=run_face_area_model3(net,ndata,'mode',m);
    fresp=smooth_half_rect(netf.content.layers{4}.unitProperties.resp);

    neto=run_face_area_model3(net,odata,'mode',m);
    oresp=smooth_half_rect(neto.content.layers{4}.unitProperties.resp);

    netb=run_face_area_model3(net,zeros(size(ndata,1),1),'mode',m);
    bresp=smooth_half_rect(netb.content.layers{4}.unitProperties.resp);

    f=mean(fresp(:,fs)-bresp(fs),1);
    o=mean(oresp(:,fs)-bresp(fs),1);
    sel=(f-o)./(f+o);

    figure(h1);
    histogram(sel,-1:1/6:2,'normalization','probability','facecolor',face_colors{I});
    hold on;
    
    resp=[fresp; oresp];
    [~,idx]=sort(resp,1,'descend');
    nface=sum(idx(1:10,fs)<=size(ndata,2),1);
    figure(h2);
    histogram(nface,'normalization','probability','facecolor',face_colors{I},'binmethod','integers','binlimits',[-1 11]);
    hold on;
    
end;

figure(h1);
xlim([-1 2]);
plot([-1/3 -1/3],ylim,'k--');
plot([1/3 1/3],ylim,'k--');
ylabel('# of images (%)');
xlabel('face selectivity index');
set(gca,'FontName','Times','FontSize',12);
set(gca,'YTickLabel',get(gca,'YTick')*100);

figure(h2);
xlim([-1 11]);
ylabel('# of images (%)');
xlabel('# of faces in top 10 images');
set(gca,'FontName','Times','FontSize',12);
set(gca,'YTickLabel',get(gca,'YTick')*100);



end
