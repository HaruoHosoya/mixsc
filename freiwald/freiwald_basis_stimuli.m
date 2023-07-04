function freiwald_basis_stimuli(net,unit,features,imgs)

nparam=19;
nvalue=11;

sz=sqrt(size(imgs,1));
nfeatures=length(features);
imgs=reshape(imgs,sz,sz,nvalue,nparam);
imgs=imgs(:,:,[1 3 5 6 7 9 11],features);
imgs=reshape(imgs,sz,sz,1,7*nfeatures);
imgs=repmat((imgs+1)/2,1,1,3,1);

figure;

v2s_bases(net,'units',repmat(unit,1,nfeatures*7),'onlyextreme',true,'disp_width',7,'bgimages',imgs,'numtoshow',100)


end

   