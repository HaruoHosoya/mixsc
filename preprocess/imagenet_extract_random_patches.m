function imagenet_extract_random_patches(indir,outdir,patch_width,sampling_rate,group_size,varargin)

pr=inputParser;
pr.addParamValue('minstd',0,@isnumeric);
pr.addParamValue('normalize',false,@islogical);
pr.addParamValue('scale',1,@isnumeric);
pr.addParamValue('wholeimage',false,@islogical);
pr.parse(varargin{:});
pr=pr.Results;

files=dir([indir '/*.h5']);
nfiles=length(files);

patches=zeros(patch_width*pr.scale,patch_width*pr.scale,group_size);
x=zeros(group_size,1);
y=zeros(group_size,1);
t=zeros(group_size,1);
f=zeros(group_size,1);

groupi=1;
patchi=1;
loadi=1;
for I=1:nfiles
    fname=[indir '/' files(I).name];
    info=h5info(fname,'/dataset');
    nimages=length(info.Datasets);
    imagenums=randi(nimages,1,floor(nimages*sampling_rate));
    fprintf('loading file#%d %s...\n',I,fname);
    if sampling_rate>1
        images=cell(nimages,1);
        for J=1:nimages
            images{J}=h5read(fname,['/dataset/' info.Datasets(J).Name]);
        end;
    end;    
    npatches=0;
    for J=imagenums
        if sampling_rate>1
            image=images{J};
        else
            image=h5read(fname,['/dataset/' info.Datasets(J).Name]);
        end;
        image=double(image);
        image=image-mean(image(:));
        image=image./std(image(:));
        [height,width]=size(image);
        loadi=loadi+1;
        t(patchi)=J;
        f(patchi)=I;
        if pr.wholeimage
            if height>width
                image=image(floor((height-width)/2)+1:floor((height-width)/2)+width,:);
            else
                image=image(:,floor((width-height)/2)+1:floor((width-height)/2)+height);
            end;
            patch=imresize(image,[patch_width,patch_width]); 
            x(patchi)=1; y(patchi)=1;
        else            
            x(patchi)=randi(width-patch_width);
            y(patchi)=randi(height-patch_width);
            patch=image(y(patchi):y(patchi)+patch_width-1,x(patchi):x(patchi)+patch_width-1);
        end;
        if std(patch(:))<pr.minstd continue; end;
        if pr.normalize
            patch=patch-mean(patch(:));
            patch=patch/std(patch(:));
        end;
        if pr.scale~=1
            patch=imresize(patch,pr.scale);
        end;
        patches(:,:,patchi)=patch;
        patchi=patchi+1; npatches=npatches+1; 
        if patchi>group_size
            outfile=sprintf('%s/patches%06d.h5',outdir,groupi);
            fprintf('saving %s...\n',outfile); 
            pos=[x y t f];
            h5create(outfile,'/data',size(patches),'ChunkSize',[patch_width*pr.scale,patch_width*pr.scale,1],'Deflate',1);
            h5write(outfile,'/data',patches);
            h5create(outfile,'/pos',size(pos));
            h5write(outfile,'/pos',pos);
            h5create(outfile,'/sampling_rate',1);
            h5write(outfile,'/sampling_rate',sampling_rate);    
            h5create(outfile,'/acceptance_rate',1);
            h5write(outfile,'/acceptance_rate',(patchi-1)/(loadi-1));    
            h5create(outfile,'/rescale',1);
            h5write(outfile,'/rescale',pr.scale);    
            groupi=groupi+1;
            patchi=1; loadi=1;
        end;                
    end;
    fprintf('(%d/%d patches loaded)\n',npatches,nimages);    
end;


end

    
    


