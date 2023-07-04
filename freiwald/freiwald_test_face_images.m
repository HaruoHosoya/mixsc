function [imgs_w_face,imgs_wo_face,params]=freiwald_test_face_images(sz)

nparam=19;
nvalue=11;

params=zeros(nvalue,nparam,nparam);

for P=1:nparam
    params(:,P,P)=-5:5;
end;

imgs_w_face=zeros(sz,sz,nvalue,nparam);
imgs_wo_face=zeros(sz,sz,nvalue,nparam);

parts=false(6,nparam);
parts(1,1:3)=true;
parts(2,4:5)=true;
parts(3,6:8)=true;
parts(4,9:13)=true;
parts(5,14:16)=true;
parts(6,17:19)=true;
parts(7,9:13)=true;

for P=1:nparam
    imgs_w_face(:,:,:,P)=cartoonStimuli(params(:,:,P),sz,false,true(7,1));
    imgs_wo_face(:,:,:,P)=cartoonStimuli(params(:,:,P),sz,false,parts(:,P));
end;

imgs_w_face=reshape(imgs_w_face,sz,sz,nvalue*nparam);
imgs_wo_face=reshape(imgs_wo_face,sz,sz,nvalue*nparam);

params=reshape(params,nvalue*nparam,nparam);

end

