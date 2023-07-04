function [imgs,params]=freiwald_random_face_images(sz,idx,len)

len=floor(len/12)*12;

p=randi(11,length(idx),len)-6;

params=zeros(19,len);
params(idx,:)=p;

params=reshape(params,19,len/12,12);

imgs=zeros(sz,sz,len/12,12);

% parfor I=1:12
for I=1:12
    imgs(:,:,:,I)=cartoonStimuli(params(:,:,I)',sz,false,true(7,1));
end;

imgs=reshape(imgs,sz,sz,len);
params=reshape(params,19,len);

end



