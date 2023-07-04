%%

figure;
show_bases(bnd_100_400.netb,'units',1:32,'disp_width',8);
plot2pdf(gcf,[result_dir 'fig/basis-many.pdf'],'size',[40 20]);
close(gcf);

%%

figure;
show_bases(bnd_100_400.netb,'units',401:432,'disp_width',8);
plot2pdf(gcf,[result_dir 'fig/basis-many-obj.pdf'],'size',[40 20]);
close(gcf);

%%

figure;
show_bases(bnd_100_400.netb,'units',[16 18 46],'disp_width',3);
plot2pdf(gcf,[result_dir 'fig/basis-few.pdf'],'size',[30 15]);
close(gcf);

%%

[h1,h2]=face_selectivity(bnd_100_400.netf_mix,ndata(:,ntest),odata(:,otest),'linear',false,'mode','mix');
plot2pdf(h1,[result_dir 'fig/select-ave.pdf'],'size',[40 20]);
plot2pdf(h2,[result_dir 'fig/select-map.pdf'],'size',[40 20]);
close(h1);
close(h2);

%%

[h1,h2]=face_selectivity(bnd_100_400.netf_sc,ndata(:,ntest),odata(:,otest),'linear',false,'mode','sc');
plot2pdf(h1,[result_dir 'fig/select-ave-sc.pdf'],'size',[40 20]);
plot2pdf(h2,[result_dir 'fig/select-map-sc.pdf'],'size',[40 20]);
close(h1);
close(h2);

%%

freiwald_show_tuning(bnd_100_400.netf_mix,[16 18 46],'tuning','full');
plot2pdf(gcf,[result_dir 'fig/tuning-few.pdf'],'size',[40 10]);
close(gcf);

%%

[h1,h2]=freiwald_show_stat(bnd_100_400.netf_mix,'tuning','full','all_in_one',true);
plot2pdf(h1,[result_dir 'fig/tuning-all-in-one.pdf'],'size',[10 40]);
close(h1);
close(h2);

%%

[h1,h2]=freiwald_show_stat(bnd_100_400.netf_mix,'tuning','full','all_in_one',false);
plot2pdf(h1,[result_dir 'fig/tuning-all.pdf'],'size',[20 40]);
plot2pdf(h2,[result_dir 'fig/tuning-all-sum.pdf'],'size',[30 15]);
close(h1);
close(h2);

%%

[h1,h2]=freiwald_show_stat3(bnd_100_400.netf_mix);
plot2pdf(h1,[result_dir 'fig/partial-map.pdf'],'size',[20 15]);
plot2pdf(h2,[result_dir 'fig/partial.pdf'],'size',[25 10]);
close(h1);
close(h2);

%%

[h1,h2]=freiwald_show_stat3(bnd_100_400.netf_sc);
plot2pdf(h1,[result_dir 'fig/partial-map-sc.pdf'],'size',[20 15]);
set(h2,'Renderer','Painter');
plot2pdf(h2,[result_dir 'fig/partial-sc.pdf'],'size',[25 10]);
close(h1);
close(h2);

%%

freiwald_show_stat2(bnd_100_400.netf_mix);
plot2pdf(gcf,[result_dir 'fig/2d-tuning.pdf'],'size',[15 10]);
close(gcf);

%%

figure;
show_bases(bnd_100_400.netb,'units',1:16,'disp_width',4,'panel_title','none','axislabels',false);
set(gcf,'Renderer','Painter');
plot2pdf(gcf,[result_dir 'fig/basis-many-100.pdf'],'size',[15 15]);
close(gcf);

%%

figure;
show_bases(bnd_200_400.netb,'units',1:16,'disp_width',4,'panel_title','none','axislabels',false);
set(gcf,'Renderer','Painter');
plot2pdf(gcf,[result_dir 'fig/basis-many-200.pdf'],'size',[15 15]);
close(gcf);

%%

figure;
show_bases(bnd_300_400.netb,'units',1:16,'disp_width',4,'panel_title','none','axislabels',false);
set(gcf,'Renderer','Painter');
plot2pdf(gcf,[result_dir 'fig/basis-many-300.pdf'],'size',[15 15]);
close(gcf);

%%

figure;
show_bases(bnd_50_400.netb,'units',1:16,'disp_width',4,'panel_title','none','axislabels',false);
set(gcf,'Renderer','Painter');
plot2pdf(gcf,[result_dir 'fig/basis-many-50.pdf'],'size',[15 15]);
close(gcf);

%%

[h1,h2]=freiwald_show_stat(bnd_200_400.netf_mix,'tuning','full');
plot2pdf(h2,[result_dir 'fig/tuning-all-sum-200.pdf'],'size',[30 15]);
close(h1);
close(h2);

%%

[h1,h2]=freiwald_show_stat(bnd_300_400.netf_mix,'tuning','full');
plot2pdf(h2,[result_dir 'fig/tuning-all-sum-300.pdf'],'size',[30 15]);
close(h1);
close(h2);

%%

[h1,h2]=freiwald_show_stat(bnd_50_400.netf_mix,'tuning','full');
plot2pdf(h2,[result_dir 'fig/tuning-all-sum-50.pdf'],'size',[30 15]);
close(h1);
close(h2);

%%

figure;
show_bases(bnd_400_pca.netb,'units',1:16,'disp_width',6,'panel_title','none','axislabels',false);
set(gcf,'Renderer','Painter');
plot2pdf(gcf,[result_dir 'fig/basis-many-pca.pdf'],'size',[20 15]);
close(gcf);

%%

figure;
show_bases(bnd_400_lpca.netb,'units',1:24,'disp_width',6,'panel_title','none','axislabels',false);
set(gcf,'Renderer','Painter');
plot2pdf(gcf,[result_dir 'fig/basis-many-lpca.pdf'],'size',[20 15]);
close(gcf);

%%

[h1,h2]=freiwald_show_stat(bnd_400_pca.netf_ff,'tuning','full');
plot2pdf(h2,[result_dir 'fig/tuning-all-sum-pca.pdf'],'size',[30 15]);
close(h1);
close(h2);

%%

[h1,h2]=freiwald_show_stat(bnd_400_lpca.netf_ff,'tuning','full');
plot2pdf(h2,[result_dir 'fig/tuning-all-sum-lpca.pdf'],'size',[30 15]);
close(h1);
close(h2);



