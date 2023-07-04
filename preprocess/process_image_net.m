function process_image_net(indir,outdir,range,width,classes,annot)

tmpdir='/tmp/proc_imagenet_tmp';
mkdir(tmpdir);
mkdir(outdir);

if max(range)>length(classes) 
    fprintf('range has to be 1<=range<=%d\n',length(classes)); 
    return;
end;

for classi=range  %1:length(classes)
    cla=classes{classi};
    filei=1;
    for I=1:length(cla)
        idstr=id_string(cla(I));
        infile=sprintf('%s/%s.tar',indir,idstr);       
        outfile=sprintf('%s/images%03d-%03d.h5',outdir,classi,filei);
        outtmpfile=sprintf('%s/images%03d-%03d.h5',tmpdir,classi,filei);
        fprintf('processing tar#%d-%d %s --> %s...\n',classi,filei,infile,outfile);
        tic
        succ=proc_tarfile(infile,tmpdir,outtmpfile,width,idstr,annot);
        if succ
            unix(sprintf('cp %s %s',outtmpfile,outfile));
            filei=filei+1;
        end;
        toc
    end;
end;

end

function str=id_string(id)

str=sprintf('n%08d',id);

end
        
function succ=proc_tarfile(infile,tmpdir,outfile,width,wnid,annot)
    succ=false;
    if ~isfield(annot,wnid)
        fprintf('%s has no bounding box info\n',wnid);
        return;
    end;
    unix(['rm -rf ' tmpdir '/*']);
    status=unix(['tar xf ' infile ' -C ' tmpdir]);
    if status~=0
        return;
    end;
    lis=fieldnames(getfield(annot,wnid));
    nimg=length(lis);
    imgs=zeros(width,width,nimg,'uint8');
    valid=true(nimg,1);
    for I=1:nimg
        try
            img=imread(sprintf('%s/%s.JPEG',tmpdir,lis{I}));
        catch e
%             fprintf('file %s.JPEG not found\n',lis{I});
            valid(I)=false;
            continue;
        end;
        if ndims(img)>2 img=rgb2gray(img); end;
        [h,w]=size(img);
        if min(h,w)<width 
            valid(I)=false; 
            continue; 
        end;
        bb=double(getfield(annot,wnid,lis{I}));
        cx=floor(mean(bb([1,2])))+1;
        cy=floor(mean(bb([3,4])))+1;
        bw=bb(2)-bb(1)+1;
        bh=bb(4)-bb(3)+1;
        s=min([max(bw,bh),w,h]);
        x0=floor(min(w-s+1,max(1,cx-s/2)));
        y0=floor(min(h-s+1,max(1,cy-s/2)));
        img=img(y0:y0+s-1,x0:x0+s-1);
        img=imresize(img,[width,width]);
        imgs(:,:,I)=img;
    end;
    imgs(:,:,~valid)=[];
    if isempty(imgs) return; end;
    h5create(outfile,'/data',[size(imgs,1),size(imgs,2),size(imgs,3)],'ChunkSize',[size(imgs,1),size(imgs,2),1],'Deflate',1,'Datatype','uint8');
    h5write(outfile,'/data',imgs);

    [wnid,words,gloss]=read_synset_info([tmpdir '/synset_info.txt']);
    hdf5write(outfile,'/synset/wnid',wnid,'WriteMode','append');
    for I=1:length(words)
        loc=sprintf('/synset/words/%02d',I);
        hdf5write(outfile,loc,words{I},'WriteMode','append');
    end;
    hdf5write(outfile,'/synset/gloss',gloss,'WriteMode','append');
    fprintf(' saved %d/%d images\n',sum(valid),nimg);
    succ=true;
end

function [wnid,words,gloss]=read_synset_info(fname)

fid=fopen(fname);
line=fgetl(fid);
wnid=sscanf(line,'wnid: %s');
line=fgetl(fid);
words=strsplit(line,{' ',',',':'});
words=words(2:end);
line=fgetl(fid);
gloss=strsplit(line,': ');
gloss=gloss{2};
fclose(fid);

end

% function process_image_net(indir,outdir,width)
% 
% tmpdir='/tmp/proc_imagenet_tmp';
% mkdir(tmpdir);
% mkdir(outdir);
% 
% tarfiles=dir([indir '/*.tar']);
% 
% for tari=1:length(tarfiles)
%     fprintf('processing tar#%d %s...\n',tari,tarfiles(tari).name);
%     tic
%     data=proc_tarfile([indir '/' tarfiles(tari).name],tmpdir,outdir,width);
%     toc
%     outname=sprintf('%s/images%05d.h5',outdir,tari);
%     fprintf('saving %s...\n',outname);
%     h5create(outname,'/data',size(data),'ChunkSize',[size(data,1),size(data,2),1],'Deflate',1,'Datatype','uint8');
%     h5write(outname,'/data',data);
% end;
% 
% 
% end
% 
% function data=proc_tarfile(tarfile,tmpdir,outdir,width)
%     unix(['rm -rf ' tmpdir '/*']);
%     unix(['tar xf ' tarfile ' -C ' tmpdir]);
%     imagefiles=dir([tmpdir '/n*.JPEG']);
%     len=length(imagefiles);
%     data=zeros(width,width,len,'uint8');
%     datai=1;
%     for filei=1:len
% %         fprintf(' file %s...\n',imagefiles(filei).name);
%         try
%             img=imread([tmpdir '/' imagefiles(filei).name]);
%         catch e
%             disp(e);
%             continue;
%         end;
%         if ndims(img)>2 img=rgb2gray(img); end;
%         [h,w]=size(img);
%         if h<width || w<width continue; end;
%         scale=1/floor(min(w,h)/width);
%         img=imresize(img,scale);
%         [h,w]=size(img);
%         y0=floor((h-width)/2+1); x0=floor((w-width)/2+1);
%         img=img(y0:y0+width-1,x0:x0+width-1);
%         data(:,:,datai)=img;
%         datai=datai+1;
%     end;
%     len=datai-1;
%     data=data(:,:,1:len);
% end
% 
%     
    
