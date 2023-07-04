function generate_labeled_data(indir,outdir,width,varargin)

pr=inputParser;
pr.addParamValue('normalize',false,@islogical);
pr.parse(varargin{:});
pr=pr.Results;

len_per_file=100000;

files=dir([indir '/*.h5']);
nfiles=length(files);

images=[];
labels=[];

total_len=0;
filei=1;
for I=1:nfiles
    spl=textscan(files(I).name,'images%03d-%03d.h5'); lab=spl{1};
    fname=sprintf('%s/%s',indir,files(I).name);
    images1=h5read(fname,'/data');
    images2=zeros(width,width,size(images1,3));
    labels2=zeros(size(images1,3),1);
    fprintf('reading %s...\n',fname);
    for J=1:size(images1,3)
        img=imresize(images1(:,:,J),[width width]);
        if pr.normalize
            img=img-mean(img(:));
            img=img/std(img(:));
        end;
        images2(:,:,J)=img;
        labels2(J,1)=lab;
    end;
    images=cat(3,images,images2);
    labels=cat(1,labels,labels2);
    if size(images,3)>len_per_file || I==nfiles
        fname=sprintf('%s/data%05d.h5',outdir,filei);
        fprintf('writing %s...\n',fname);
        h5create(fname,'/data',size(images));
        h5write(fname,'/data',images);
        h5create(fname,'/labels',size(labels));
        h5write(fname,'/labels',labels);
        total_len=total_len+size(images,3);
        images=[]; labels=[];
        filei=filei+1;
    end;        
end;

fprintf('total length: %d\n',total_len);

end

    
    


