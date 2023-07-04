function bnd=go_build_model(ndata,odata,nfo,nrd,learning,varargin)

switch(learning)
    case 'smica-sep'
        [netf,netb]=build_face_area_model4(ndata,odata,nfo,nfo,'npos',10,'learning','smica-sep','lastEig',nrd,varargin{:});
    case 'pca'
        [netf,netb]=build_face_area_model4(ndata,odata,nfo,nfo,'npos',10,'learning','pca','lastEig',nrd,varargin{:});
    case 'pca-last'
        [netf,netb]=build_face_area_model4(ndata,odata,nfo,nfo,'npos',10,'learning','pca-last','lastEig',nrd,varargin{:});
    case 'pca-random'
        [netf,netb]=build_face_area_model4(ndata,odata,nfo,nfo,'npos',10,'learning','pca-random','lastEig',nrd,varargin{:});
end;

netf=set_signal_sd(netf,ndata(:,1:1000),odata(:,1:1000),'mode','sc');


bnd.netf=netf;
bnd.netb=netb;


end




        
