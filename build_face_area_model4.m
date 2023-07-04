function [netf,netb,Y]=build_face_area_model4(fdata,odata,nf,no,varargin)

pr=inputParser;
pr.addParamValue('reduction',8,@isnumeric);
pr.addParamValue('learning','ica',@isstr);
pr.addParamValue('lastEig',NaN,@isnumeric);
pr.addParamValue('epsilon',0.0005,@isnumeric);
pr.addParamValue('maxIter',100,@isnumeric);
pr.addParamValue('meanrem',false,@islogical);
pr.addParamValue('meanproj',false,@islogical);
pr.addParamValue('fix_alpha',true,@islogical);
pr.addParamValue('norient',8,@isnumeric);
pr.addParamValue('npos',14,@isnumeric);
pr.addParamValue('freqs',[1/8 1/6 1/4],@isnumeric);
pr.addParamValue('modulation',[1 1 1 1],@isnumeric);
pr.addParamValue('adjust_sign',true,@islogical);
pr.addParamValue('mean_activity',3,@isnumeric);

pr.parse(varargin{:});
options=pr.Results;

dataset=[fdata odata];
[datadim,datalen]=size(dataset); datawid=floor(sqrt(datadim));
flen=size(fdata,2);
olen=size(odata,2);
net=struct;

% v1 simple

pos=linspace(6,datawid-6,options.npos);
oris=0:pi/options.norient:pi-pi/options.norient;
freqs=options.freqs;
% phases=[0 pi/2 pi pi/2*3];
phases=[0 pi/2];
[v1s_bank,v1s_params]=gabor_bank(datawid,0.4,0.4,pos,freqs,oris,phases,1.15);
[~,npha,nori,nfreq,nx,ny]=size(v1s_bank);
v1s_nunits=npha*nori*nfreq*nx*ny;

net=addlayer(net,1,'LGN',datawid,1,datawid);
net=addlayer(net,2,'V1s',1,v1s_nunits,1);
net.content.layers{2}.layerProperties.meanrem=false;
net.content.layers{2}.layerProperties.nonlin='square';
net.content.layers{2}.layerProperties.dcrem=false;

net.content.layers{2}.weights=reshape(v1s_bank,[1,datadim,v1s_nunits,1]);
net.content.layers{2}.unitProperties.params=reshape(v1s_params,[8,v1s_nunits,1]);

% v1 complex

v1c_nunits=v1s_nunits/npha;
v1c_nreduced=floor(v1c_nunits/options.reduction);
net=addlayer(net,3,'V1c',1,v1c_nunits,1);
net.content.layers{3}.layerProperties.nonlin='sqrt';
v1c_pooling=zeros(npha,v1c_nunits,v1c_nunits);
for I=1:v1c_nunits
    v1c_pooling(:,I,I)=1;
end;
net.content.layers{3}.layerProperties.meanrem=false;
net.content.layers{3}.layerProperties.dcrem=false;
net.content.layers{3}.weights=reshape(v1c_pooling,[v1s_nunits,1,v1c_nunits,1]);
net.content.layers{3}.mean=zeros(1,v1s_nunits,1);

% IT

net=calc_coverage(net);

net=run_net(net,dataset);
v1c_outputs=reshape(net.content.layers{3}.unitProperties.resp,[datalen,v1c_nunits,1])';
v1c_mean=mean(v1c_outputs,2);

if options.meanproj
    v1c_outputs=v1c_outputs-v1c_mean/sum(v1c_mean.^2)*(v1c_mean'*v1c_outputs);
end;

if isnan(options.lastEig)
    options.lastEig=v1c_nreduced;
end;

nunits=nf+no;

U=0;
alpha=[];
b=zeros(nunits,1);

v1c_outputs_f=v1c_outputs(:,1:flen);
v1c_outputs_o=v1c_outputs(:,flen+1:end);

% bias inputs for explicit face selective units

vf1=options.modulation(1); vf0=options.modulation(2); vo1=options.modulation(3); vo0=options.modulation(4);
B=[[ones(nf,1)*vf1;ones(no,1)*vo0],[ones(nf,1)*vf0;ones(no,1)*vo1]];
l=[ones(flen,1);zeros(olen,1)];l=[l 1-l]';
bias_inputs=B*l;

% learning

switch options.learning
    case 'bica'
        [Y,A,W]=bica(v1c_outputs,bias_inputs,nunits,'lastEig',options.lastEig,'maxIter',options.maxIter,'adjust_sign',false);
    case 'bica2'
        [Y,A,W]=bica2(v1c_outputs,bias_inputs,nunits,'lastEig',options.lastEig,'maxIter',options.maxIter,'adjust_sign',false);
    case 'bsmica'
        [Y,A,W]=smica_biased(v1c_outputs,bias_inputs,nunits,'lastEig',options.lastEig,'maxIter',options.maxIter,'fix_alpha',options.fix_alpha);
    case 'ica-sep'
        [Yf,Af,Wf]=fastica(v1c_outputs_f,'numOfIC',nf,'lastEig',options.lastEig,'maxIter',options.maxIter);
        [Yo,Ao,Wo]=fastica(v1c_outputs_o,'numOfIC',no,'lastEig',options.lastEig,'maxIter',options.maxIter);
        bf=mean(Wf*v1c_outputs_f,2);
        bo=mean(Wo*v1c_outputs_o,2);
        Y=[Yf zeros(nf,olen); zeros(no,flen) Yo]; 
        A=[Af Ao]; W=[Wf; Wo]; b=[bf; bo]; 
    case 'smica-sep'
        [Yf,Af,Wf,alphaf,Uf]=smica(v1c_outputs_f,nf,'lastEig',options.lastEig,'maxIter',options.maxIter,'fix_alpha',options.fix_alpha);
        [Yo,Ao,Wo,alphao,Uo]=smica(v1c_outputs_o,no,'lastEig',options.lastEig,'maxIter',options.maxIter,'fix_alpha',options.fix_alpha);
        bf=mean(Wf*v1c_outputs_f,2);
        bo=mean(Wo*v1c_outputs_o,2);
        Y=[Yf zeros(nf,olen); zeros(no,flen) Yo]; 
        A=[Af Ao]; W=[Wf; Wo]; b=[bf; bo]; alpha=[alphaf; alphao]; U=[Uf; Uo];
    case 'sc'
        [Y,A,W]=sparse_coding(v1c_outputs,nunits,bias_inputs,'lastEig',options.lastEig,'maxIter',options.maxIter);
    case 'pca'
        nf=min(nf,options.lastEig); no=min(no,options.lastEig); nunits=nf+no;
        [Yf,Af,Wf]=whiten(v1c_outputs_f,nf);
        [Yo,Ao,Wo]=whiten(v1c_outputs_o,no);
        bf=mean(Wf*v1c_outputs_f,2);
        bo=mean(Wo*v1c_outputs_o,2);
        Y=[Yf zeros(nf,olen); zeros(no,flen) Yo]; 
        A=[Af Ao]; W=[Wf; Wo]; b=[bf; bo];         
    case 'pca-last'
        [Yf,Af,Wf]=whiten(v1c_outputs_f,v1c_nunits);
        [Yo,Ao,Wo]=whiten(v1c_outputs_o,v1c_nunits);
        Yf=Yf(end-nf+1:end,:); Yo=Yo(end-no+1:end,:);
        Af=Af(:,end-nf+1:end); Ao=Ao(:,end-no+1:end);
        Wf=Wf(end-nf+1:end,:); Wo=Wo(end-no+1:end,:);
        bf=mean(Wf*v1c_outputs_f,2);
        bo=mean(Wo*v1c_outputs_o,2);
        Y=[Yf zeros(nf,olen); zeros(no,flen) Yo]; 
        A=[Af Ao]; W=[Wf; Wo]; b=[bf; bo];         
    case 'pca-random'
%         [E,~,D]=pca(v1c_outputs','NumComponents',options.lastEig);
        [Yf,Af,Wf]=whiten(v1c_outputs_f,options.lastEig);
        [Yo,Ao,Wo]=whiten(v1c_outputs_o,options.lastEig);
        Uf=rand(nf,options.lastEig)*2-1;
        Uf=bsxfun(@rdivide,Uf,sqrt(sum(Uf.^2,2)));
%         Uf=((Uf*Uf')^(-1/2))'*Uf;
        Uo=rand(no,options.lastEig)*2-1;
        Uo=bsxfun(@rdivide,Uo,sqrt(sum(Uo.^2,2)));
%         Uo=((Uo*Uo')^(-1/2))'*Uo;
        Wf=Uf*Wf; Af=Af*Uf';
        Wo=Uo*Wo; Ao=Ao*Uo';
        bf=mean(Wf*v1c_outputs_f,2);
        bo=mean(Wo*v1c_outputs_o,2);
        Yf=bsxfun(@minus,Wf*v1c_outputs_f,bf);
        Yo=bsxfun(@minus,Wo*v1c_outputs_o,bo);
        Y=[Yf zeros(nf,olen); zeros(no,flen) Yo]; 
        A=[Af Ao]; W=[Wf; Wo]; b=[bf; bo];         
    case 'random'
        Wf=rand(nf,v1c_nunits)*2-1;
        vf=std(Wf*v1c_outputs_f,[],2);
        Wf=bsxfun(@rdivide,Wf,vf); Af=Wf';
        Wo=rand(no,v1c_nunits)*2-1;
        vo=std(Wo*v1c_outputs_o,[],2);
        Wo=bsxfun(@rdivide,Wo,vo); Ao=Wo';
        bf=mean(Wf*v1c_outputs_f,2);
        bo=mean(Wo*v1c_outputs_o,2);
        Yf=bsxfun(@minus,Wf*v1c_outputs_f,bf);
        Yo=bsxfun(@minus,Wo*v1c_outputs_o,bo);
        Y=[Yf zeros(nf,olen); zeros(no,flen) Yo]; 
        A=[Af Ao]; W=[Wf; Wo]; b=[bf; bo];         
    case 'mean'
        nunits=1;
        W=reshape(v1c_mean,1,v1c_nunits);
        A=W';
        Y=W*v1c_outputs;
    case 'mlp'
        mlp.nonlin={'','softplus','linear'};
        mlp.nlayer=3;
        mlp.W={[],rand(nunits,v1c_nunits)*0.01-0.005,rand(2,nunits)*0.01-0.005};
        answers=zeros(2,flen+olen); answers(1,1:flen)=1; answers(2,flen+1:end)=1;
        mlp=learn_mlp(mlp,v1c_outputs,answers,'maxIter',options.maxIter);
        W=mlp.W{2}; 
        b=zeros(nunits,1); A=W'; Y=W*v1c_outputs;
        net.mlp=mlp;
    otherwise
        error('no such learning supported');
end;

net=addlayer(net,4,'IT',1,nunits,1);
net.content.layers{4}.layerProperties.meanrem=options.meanrem;
net.content.layers{4}.layerProperties.meanproj=options.meanproj;
net.content.layers{4}.layerProperties.nonlin='linear';
% net.content.layers{4}.layerProperties.nonlin='half-rect';
net.content.layers{4}.layerProperties.dcrem=false;

net.content.layers{4}.mean=zeros(1,v1c_nunits,1);
net=calc_coverage(net);

if options.adjust_sign
    resp=W*v1c_outputs; 
    mf=skewness(resp(:,1:flen),[],2); mo=skewness(resp(:,flen+1:end),[],2);
%     s=[mf(1:nf)>0; mo(nf+1:end)>0];
    s=b>0;
    W=bsxfun(@times,W,s*2-1);
    A=bsxfun(@times,A,s'*2-1);
    Y=bsxfun(@times,Y,s*2-1);
    b=bsxfun(@times,b,s*2-1);
end;

% center=ones(nunits,1)*options.mean_activity;
% % inputbase=[mean(v1c_outputs_f,2)-A(:,1:nf)*center(1:nf,1) mean(v1c_outputs_o,2)-A(:,nf+1:nf+no)*center(nf+1:nf+no,1)];
inputbase=[mean(v1c_outputs_f,2) mean(v1c_outputs_o,2)];  % fixed from 160727 version

center=b;
% inputbase=zeros(v1c_nunits,2);  % this is incorrect

net.content.layers{4}.mean=reshape(v1c_mean,1,v1c_nunits,1);

net.content.layers{4}.weights=reshape(W',[v1c_nunits,1,nunits,1]);
net.content.layers{4}.center=center;
net.content.layers{4}.inputbase=inputbase;

net.content.layers{4}.rotation_weights=U;
net.content.layers{4}.unitProperties.alpha=alpha;
net.content.layers{4}.face_selective=1:nf;

net=v1c_analyze(net);
net=compose_bases(net);

net=strip_resp(net);


% basis & filter representations

netf=net;
netb=net;

netf.content.layers{4}.basis=reshape(A,[v1c_nunits,1,nunits,1]);

netb.content.layers{4}.weights=reshape(A,[v1c_nunits,1,nunits,1]);
netb=compose_bases(netb);


end

function [Y,A,W]=whiten(d,nunits)

[E,S,D]=pca(d','NumComponents',nunits);
W=(diag(D(1:nunits).^(-1/2)))*E'; 
A=E*(diag(D(1:nunits).^(1/2))); 
Y=bsxfun(@times,S',D(1:nunits).^(-1/2));

end
