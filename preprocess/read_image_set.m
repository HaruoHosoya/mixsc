function images=read_image_set(indir,wid,ext)

dd=dir([indir '/*.' ext]);
idx=arrayfun(@(d)(d.name(1)~='.' && ~d.isdir),dd);
dd(~idx)=[];

images=zeros(wid,wid,length(dd));

for J=1:length(dd)
    img=imread([indir '/' dd(J).name]);
    if ndims(img)==3
        img=rgb2gray(img);
    end;
    [imhit imwid]=size(img);
    if imhit>imwid 
        y=floor((imhit-imwid)/2)+1;
        img=img(y:y+imwid-1,1:end);
    else
        x=floor((imwid-imhit)/2)+1;
        img=img(1:end,x:x+imhit-1);
    end;
    img=imresize(img,[wid wid]);
    img=double(img);
    img=img-mean(img(:));
    img=img/std(img(:));
    images(:,:,J)=img;
end

end
