function images=process_lfw(indir,wid)

d=dir(indir);

nimages=0;

for I=1:length(d)
    if d(I).name(1)~='.' && d(I).isdir
        fprintf('searching %s\n',d(I).name);
        dd=dir([indir '/' d(I).name '/*.jpg']);
        for J=1:length(dd)
            if dd(J).name(1)~='.' && ~dd(J).isdir
                nimages=nimages+1;
            end;
        end;
    end;
end;

images=zeros(wid,wid,nimages);

num=1;
for I=1:length(d)
    if d(I).name(1)~='.' && d(I).isdir
        fprintf('processing %s\n',d(I).name);
        dd=dir([indir '/' d(I).name '/*.jpg']);
        for J=1:length(dd)
            if dd(J).name(1)~='.' && ~dd(J).isdir
%                 fprintf('loading %s\n',[indir '/' dd(J).name]);
                img=imread([indir '/' d(I).name '/' dd(J).name]);
                img=rgb2gray(img);
                img=imresize(img,[wid wid]);
                img=double(img);
                img=img-mean(img(:));
                img=img/std(img(:));
                images(:,:,num)=img;
                num=num+1;
            end;
        end;
    end;
end;

end

        