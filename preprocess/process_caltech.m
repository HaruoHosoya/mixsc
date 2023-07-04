function [images,labels]=process_caltech(indir,wid,ext)

if ~exist('ext','var') ext='jpg'; end;

ds=dir(indir);
image_set={};
label_set={};

ds(1:2)=[];

for I=1:length(ds)
    indir2=[indir '/' ds(I).name];
    fprintf('reading from %s\n',indir2);
    image_set{I}=read_image_set(indir2,wid,ext);
    label_set{I}=ones(size(image_set{I},3),1)*I;
end;

images=cat(3,image_set{:});
labels=cat(1,label_set{:});

end
