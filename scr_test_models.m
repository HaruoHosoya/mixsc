%%
%% loading
%%

%%

load([result_dir 'bnd_100_400']);

%%

load([result_dir 'bnd_100_200']);

%%

load([result_dir 'bnd_100_800']);

%%

load([result_dir 'bnd_200_400']);

%%

load([result_dir 'bnd_300_400']);

%%

load([result_dir 'bnd_400_400']);

%%

load([result_dir 'bnd_50_400']);

%%

load([result_dir 'bnd_400_pca']);

%%

load([result_dir 'bnd_400_lpca']);

%%

load([result_dir 'bnd_400_rpca']);

%%
%% Freiwald&Tsao analysis
%%

bnd_100_400=go_test_model(bnd_100_400,cdata,cparams,cdata1d,cdata1d_noface,cparams1d);

%%

bnd_100_200=go_test_model(bnd_100_200,cdata,cparams,cdata1d,cdata1d_noface,cparams1d);

%%

bnd_100_800=go_test_model(bnd_100_800,cdata,cparams,cdata1d,cdata1d_noface,cparams1d);

%%

bnd_200_400=go_test_model(bnd_200_400,cdata,cparams,cdata1d,cdata1d_noface,cparams1d);

%%

bnd_300_400=go_test_model(bnd_300_400,cdata,cparams,cdata1d,cdata1d_noface,cparams1d);

%%

bnd_400_400=go_test_model(bnd_400_400,cdata,cparams,cdata1d,cdata1d_noface,cparams1d);

%%

bnd_50_400=go_test_model(bnd_50_400,cdata,cparams,cdata1d,cdata1d_noface,cparams1d);

%%

bnd_400_pca=go_test_model(bnd_400_pca,cdata,cparams,cdata1d,cdata1d_noface,cparams1d);

%%

bnd_400_lpca=go_test_model(bnd_400_lpca,cdata,cparams,cdata1d,cdata1d_noface,cparams1d);

%%

bnd_400_rpca=go_test_model(bnd_400_rpca,cdata,cparams,cdata1d,cdata1d_noface,cparams1d);

%%
%% displaying
%%

go_display(bnd_100_400,ndata(:,ntest),odata(:,otest),cdatap,cmasksp,'mix','full');

%%

go_display(bnd_100_400,ndata(:,ntest),odata(:,otest),cdatap,cmasksp,'sc','full');

%%

go_display(bnd_100_200,ndata(:,ntest),odata(:,otest),cdatap,cmasksp,'mix','full');

%%

go_display(bnd_100_800,ndata(:,ntest),odata(:,otest),cdatap,cmasksp,'mix','full');

%%

go_display(bnd_200_400,ndata(:,ntest),odata(:,otest),cdatap,cmasksp,'mix','full');

%%

go_display(bnd_300_400,ndata(:,ntest),odata(:,otest),cdatap,cmasksp,'mix','full');

%%

go_display(bnd_400_400,ndata(:,ntest),odata(:,otest),cdatap,cmasksp,'mix','full');

%%

go_display(bnd_50_400,ndata(:,ntest),odata(:,otest),cdatap,cmasksp,'mix','full');

%%

go_display(bnd_400_pca,ndata(:,ntest),odata(:,otest),cdatap,cmasksp,'ff','full');

%%

go_display(bnd_400_rpca,ndata(:,ntest),odata(:,otest),cdatap,cmasksp,'ff','full');

%%

go_display(bnd_400_lpca,ndata(:,ntest),odata(:,otest),cdatap,cmasksp,'ff','full');

