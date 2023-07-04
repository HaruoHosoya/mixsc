%%

arg={'maxiter',1000,'meanproj',false,'meanrem',false,'adjust_sign',false,'mean_activity',3.0};

%%

bnd_100_400=go_build_model(ndata(:,ntrain),odata(:,otrain),400,100,'smica-sep',arg{:});

%%

bnd_100_200=go_build_model(ndata(:,ntrain),odata(:,otrain),200,100,'smica-sep',arg{:});

%%

bnd_100_800=go_build_model(ndata(:,ntrain),odata(:,otrain),800,100,'smica-sep',arg{:});

%%

bnd_200_400=go_build_model(ndata(:,ntrain),odata(:,otrain),400,200,'smica-sep',arg{:});

%%

bnd_300_400=go_build_model(ndata(:,ntrain),odata(:,otrain),400,300,'smica-sep',arg{:});

%%

bnd_400_400=go_build_model(ndata(:,ntrain),odata(:,otrain),400,400,'smica-sep',arg{:});

%%

bnd_50_400=go_build_model(ndata(:,ntrain),odata(:,otrain),400,50,'smica-sep',arg{:});

%%

bnd_400_pca=go_build_model(ndata(:,ntrain),odata(:,otrain),400,400,'pca',arg{:});

%%

bnd_400_lpca=go_build_model(ndata(:,ntrain),odata(:,otrain),400,400,'pca-last',arg{:});

%%

bnd_400_rpca=go_build_model(ndata(:,ntrain),odata(:,otrain),400,400,'pca-random',arg{:});

%%

save([result_dir 'bnd_100_400'],'bnd_100_400','-v7.3');

%%

save([result_dir 'bnd_100_200'],'bnd_100_200','-v7.3');

%%

save([result_dir 'bnd_100_800'],'bnd_100_800','-v7.3');

%%

save([result_dir 'bnd_200_400'],'bnd_200_400','-v7.3');

%%

save([result_dir 'bnd_300_400'],'bnd_300_400','-v7.3');

%%

save([result_dir 'bnd_400_400'],'bnd_400_400','-v7.3');

%%

save([result_dir 'bnd_50_400'],'bnd_50_400','-v7.3');

%%

save([result_dir 'bnd_400_pca'],'bnd_400_pca','-v7.3');

%%

save([result_dir 'bnd_400_lpca'],'bnd_400_lpca','-v7.3');

%%

save([result_dir 'bnd_400_rpca'],'bnd_400_rpca','-v7.3');

%%
