function annot=process_image_net_annotation(indir,range)

tmpdir='/tmp/proc_imagenet_tmp';
mkdir(tmpdir);

tarfiles=dir([indir '/*.tar.gz']);

if ~exist('range','var')
    range=1:length(tarfiles);
elseif max(range)>length(tarfiles) 
    fprintf('range has to be 1<=range<=%d\n',length(tarfiles)); 
    return;
end;

annot={};
for tari=range  %1:length(tarfiles)
    spl=strsplit(tarfiles(tari).name,'.'); trunk=spl{1};
    infile=sprintf('%s/%s.tar.gz',indir,trunk);
    fprintf('processing tar#%d %s.tar ...\n',tari,trunk);
    tic
    unix(['rm -rf ' tmpdir '/*']);
    unix(['tar xfz ' infile ' -C ' tmpdir]);
    xmlfiles=dir(sprintf('%s/Annotation/%s/*.xml',tmpdir,trunk));
    len=length(xmlfiles);
    for filei=1:len
        spl=strsplit(xmlfiles(filei).name,{'.'}); idstr=spl{1};
        spl=strsplit(idstr,{'_'}); wnid=spl{1};
%         fprintf(' file %s...\n',imagefiles(filei).name);
        try
            doc=VOCreadxml(sprintf('%s/Annotation/%s/%s.xml',tmpdir,trunk,idstr));
        catch e
            disp(e);
            continue;
        end;
        bb=doc.annotation.object.bndbox;
        xmin=str2double(bb.xmin); xmax=str2double(bb.xmax);
        ymin=str2double(bb.ymin); ymax=str2double(bb.ymax);
        annot=setfield(annot,wnid,idstr,[xmin xmax ymin ymax]);
    end;
    toc
end;


end

