function net=run_face_area_model3(net,data,varargin)

pr=inputParser;
pr.addParamValue('mode','ff',@isstr);
pr.addParamValue('ignore_signal_sd',false,@islogical);

pr.parse(varargin{:});
options=pr.Results;

net=run_net(net,data);

inp=net.content.layers{3}.unitProperties.resp;
resp1=net.content.layers{4}.unitProperties.resp;

layer=net.content.layers{4};

if isfield(layer.layerProperties,'meanrem') && layer.layerProperties.meanrem
    inp=bsxfun(@minus,inp,layer.mean);
end;
if isfield(layer.layerProperties,'meanproj') && layer.layerProperties.meanproj
    inp=inp-(inp*layer.mean')*layer.mean/sum(layer.mean.^2);
end;

basis=net.content.layers{4}.basis;
basis=reshape(basis,size(basis,1),size(basis,3));

weights=net.content.layers{4}.weights;
weights=reshape(weights,size(weights,1),size(weights,3));

inputbase=net.content.layers{4}.inputbase;
center=net.content.layers{4}.center;

options.maxIterIn=200;
options.rho=1;
% options.lambda=10;
options.lambda=1000;
        
nunits=size(basis,2);
funit=layer.face_selective;
ounit=setdiff(1:nunits,funit);
respf=resp1(:,funit);
respo=resp1(:,ounit);
basisf=basis(:,funit);
basiso=basis(:,ounit);
weightsf=weights(:,funit);
weightso=weights(:,ounit);
inputbasef=inputbase(:,1);
inputbaseo=inputbase(:,2);
centerf=center(funit,1);
centero=center(ounit,1);

rf=ones(nunits,1)*NaN;

baseline=0;

switch(options.mode)
    case 'ff'
%         respf=respf'; respo=respo';
        inpf=bsxfun(@minus,inp',inputbasef);
        inpo=bsxfun(@minus,inp',inputbaseo);
        respf=weightsf'*inpf;
        respo=weightso'*inpo;
        respf=bsxfun(@plus,respf,centerf);
        respo=bsxfun(@plus,respo,centero);
    case 'sc'
        inpf=bsxfun(@minus,inp',inputbasef);
        inpo=bsxfun(@minus,inp',inputbaseo);
        [respf,Lf,resp_trace,L_trace]=sparse_coding_map_infer(basisf,inpf,respf',options);
        [respo,Lo,resp_trace,L_trace]=sparse_coding_map_infer(basiso,inpo,respo',options);
        if ~options.ignore_signal_sd && isfield(layer.unitProperties,'signal_sd')
            signal_sd=layer.unitProperties.signal_sd';
            respf=bsxfun(@rdivide,respf,signal_sd(funit));
            respo=bsxfun(@rdivide,respo,signal_sd(ounit));        
        end;
        respf=bsxfun(@plus,respf,centerf);
        respo=bsxfun(@plus,respo,centero);
    case 'mix'
        inpf=bsxfun(@minus,inp',inputbasef);
        inpo=bsxfun(@minus,inp',inputbaseo);
        [respf,Lf,resp_trace,L_trace]=sparse_coding_map_infer(basisf,inpf,respf',options);
        [respo,Lo,resp_trace,L_trace]=sparse_coding_map_infer(basiso,inpo,respo',options);
        if ~options.ignore_signal_sd && isfield(layer.unitProperties,'signal_sd')
            signal_sd=layer.unitProperties.signal_sd';
            respf=bsxfun(@rdivide,respf,signal_sd(funit));
            respo=bsxfun(@rdivide,respo,signal_sd(ounit));        
        end;
        respf=bsxfun(@plus,respf,centerf);
        respo=bsxfun(@plus,respo,centero);
        % completely MAP
%         idx=Lf>Lo;
%         respo(:,idx==1)=0;
%         respf(:,idx==0)=0;
        % more Bayesian
        rf=1./(1+exp(Lo-Lf));
        ro=1./(exp(Lf-Lo)+1);
        respf=bsxfun(@plus,bsxfun(@times,respf,rf),bsxfun(@times,baseline,ro));
        respo=bsxfun(@plus,bsxfun(@times,respo,ro),bsxfun(@times,baseline,rf));
end;

net.content.layers{4}.unitProperties.resp=[respf; respo]';
net.content.layers{4}.unitProperties.prob_face=rf;



end

