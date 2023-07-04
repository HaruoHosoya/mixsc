%% load natural face datasets (deep funneled)

df_imgs128=h5read([dataset_dir 'face_images.h5'],'/data');

%% load cartoon faces

load([dataset_dir 'cartoon_face_data.mat'],'cartoon_face_data');
cimgdata=cartoon_face_data.cimgdata;
cparams=cartoon_face_data.cparams;
cimgdata1d=cartoon_face_data.cimgdata1d;
cimgdata1d_noface=cartoon_face_data.cimgdata1d_noface;
cparams1d=cartoon_face_data.cparams1d;
cimgdatap=cartoon_face_data.cimgdatap;
cmasksp=cartoon_face_data.cmasksp;

%% load object image datasets

oimgdata=h5read([dataset_dir 'object_images.h5'],'/data');

%% load mosaic faces

% load([result_dir 'mosaic_face_data.mat'],'mosaic_face_data');
% himgdata=mosaic_face_data.himgdata;
% hparams=mosaic_face_data.hparams;

%%
% whole faces 

% filter for focusing on the eyes

% [ix,iy]=ndgrid(1:64,1:64);
% filt=gauss2(ix,iy,31,32,25,30);
% % filt=gauss2(ix,iy,31,20,15,15)+gauss2(ix,iy,31,44,15,15);

%% filter for emphasizing faces

[ix,iy]=ndgrid(1:64,1:64);
filt=min(1,gauss2(ix,iy,31,32,20,20)*3);

%% no filter

% filt=ones(64);

%% natural faces

imgdata=imresize_all(df_imgs128(20:99,26:105,:),[64 64]);
imgdata_filt=bsxfun(@times,filt,imgdata);
ndata=reshape(imgdata_filt,size(imgdata,1)*size(imgdata,2),size(imgdata,3));
ndata=bsxfun(@minus,ndata,mean(ndata,1));
ndata=bsxfun(@rdivide,ndata,std(ndata,0,1));

%% cartoon faces

cimgdata1=cimgdata(35:end-15,25:end-25,:);
cimgdata1=imresize_all(cimgdata1,[64 64]);
cimgdata_filt=bsxfun(@times,filt,cimgdata1);
cdata=reshape(cimgdata_filt,size(cimgdata_filt,1)*size(cimgdata_filt,2),size(cimgdata_filt,3));
mean_cdata=mean(cdata(:));
std_cdata=std(cdata(:));
cdata=cdata-mean_cdata;
cdata=cdata/std_cdata;

%% cartoon faces (1d)

cimgdata1d1=cimgdata1d(35:end-15,25:end-25,:);
cimgdata1d1=imresize_all(cimgdata1d1,[64 64]);
cimgdata1d_filt=bsxfun(@times,filt,cimgdata1d1);
cimgdata1d_noface1=cimgdata1d_noface(35:end-15,25:end-25,:);
cimgdata1d_noface1=imresize_all(cimgdata1d_noface1,[64 64]);
cimgdata1d_noface_filt=bsxfun(@times,filt,cimgdata1d_noface1);
cdata1d=reshape(cimgdata1d_filt,size(cimgdata1d_filt,1)*size(cimgdata1d_filt,2),size(cimgdata1d_filt,3));
cdata1d_noface=reshape(cimgdata1d_noface_filt,size(cimgdata1d_noface_filt,1)*size(cimgdata1d_noface_filt,2),size(cimgdata1d_noface_filt,3));
cdata1d=cdata1d-mean_cdata;
cdata1d=cdata1d/std_cdata;
cdata1d_noface=cdata1d_noface-mean_cdata;
cdata1d_noface=cdata1d_noface/std_cdata;

%% cartoon faces (partial)

cimgdatap1=cimgdatap(35:end-15,25:end-25,:);
cimgdatap1=imresize_all(cimgdatap1,[64 64]);
cimgdatap_filt=bsxfun(@times,filt,cimgdatap1);
cdatap=reshape(cimgdatap_filt,size(cimgdatap_filt,1)*size(cimgdatap_filt,2),size(cimgdatap_filt,3));
mean_cdatap=mean(cdatap(:));
std_cdatap=std(cdatap(:));
cdatap=cdatap-mean_cdatap;
cdatap=cdatap/std_cdatap;

%% object images

oimgdata_filt=bsxfun(@times,filt,oimgdata);
odata=reshape(oimgdata_filt,size(oimgdata,1)*size(oimgdata,2),size(oimgdata,3));
odata=bsxfun(@minus,odata,mean(odata,1));
odata=bsxfun(@rdivide,odata,std(odata,0,1));

%% mosaic face images

% himgdata_filt=bsxfun(@times,filt,himgdata);
% hdata=reshape(himgdata_filt,size(himgdata,1)*size(himgdata,2),size(himgdata,3));
% hdata=hdata-mean(hdata(:));
% hdata=hdata/std(hdata(:));
 
%%

rng_cur=rng;
rng(0,'twister');
ntest=randperm(size(ndata,2),1000);
ntrain=setdiff(1:size(ndata,2),ntest);
otest=randperm(size(odata,2),1000);
otrain=setdiff(1:size(odata,2),ntest);
rng(rng_cur);



