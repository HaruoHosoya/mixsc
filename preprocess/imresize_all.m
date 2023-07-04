function imgs_out=imresize_all(imgs,sz)

if ndims(imgs)==3
    [sy,sx,len]=size(imgs);
else
    [sy,sx,~,len]=size(imgs);
end;

imgs_out=zeros(sz(1),sz(2),len);

for I=1:len
    if ndims(imgs)<=3
        im=imgs(:,:,I);
    else
        im=rgb2gray(imgs(:,:,:,I));
    end;
    imgs_out(:,:,I)=imresize(im,sz);
end;

end


    