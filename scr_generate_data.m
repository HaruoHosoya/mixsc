%% generate cartoon faces

[cimgdata,cparams]=freiwald_random_face_images(256,1:19,5000);
[cimgdata1d,cimgdata1d_noface,cparams1d]=freiwald_test_face_images(256);
[cimgdatap,cmasksp]=freiwald_partial_faces(256);

%% save cartoon faces

cartoon_face_data.cimgdata=cimgdata;
cartoon_face_data.cparams=cparams;
cartoon_face_data.cimgdata1d=cimgdata1d;
cartoon_face_data.cimgdata1d_noface=cimgdata1d_noface;
cartoon_face_data.cparams1d=cparams1d;
cartoon_face_data.cimgdatap=cimgdatap;
cartoon_face_data.cmasksp=cmasksp;

save([dataset_dir 'cartoon_face_data.mat'],'cartoon_face_data','-v7.3');

%% generate mosaic faces

% [himgdata,hparams]=ohayon_face_dataset(64);
% 
% %% save mosaic faces
% 
% mosaic_face_data.himgdata=himgdata;
% mosaic_face_data.hparams=hparams;
% 
% save([result_dir 'mosaic_face_data.mat'],'mosaic_face_data','-v7.3');

