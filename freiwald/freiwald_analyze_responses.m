function net=freiwald_analyze_responses(net,imgs,params,imgs1d,imgs1d_noface,params1d,varargin)

pr=inputParser;
pr.addParamValue('mode','mix',@isstr);
pr.addParamValue('conf_level',99.9,@isnumeric);
pr.addParamValue('noise',0,@isnumeric);

pr.parse(varargin{:});
options=pr.Results;

v2info=net.structure.layers{4};
nunit=v2info.numUnits;
% nonlin=@(x)max(x,0);
nonlin=@smooth_half_rect;

% baseline response

net=run_face_area_model3(net,zeros(size(imgs,1),1),'mode',options.mode);
% net=run_net(net,zeros(size(imgs,1),1));
resp=net.content.layers{4}.unitProperties.resp;
baseline=nonlin(resp);

% responses to cartoon face stimuli

nparam=19;
nvalue=11;
values=-5:5;

[~,len]=size(imgs);
% net=run_net(net,imgs);
net=run_face_area_model3(net,imgs,'mode',options.mode);

resp=net.content.layers{4}.unitProperties.resp;
resp=nonlin(resp);

% resp=bsxfun(@minus,resp,mean(resp,1));
% resp=bsxfun(@minus,resp,min(resp,[],1))+eps;
% resp=bsxfun(@rdivide,resp,max(resp,[],1));

% net=run_net(net,imgs1d);
net=run_face_area_model3(net,imgs1d,'mode',options.mode);

resp1d=net.content.layers{4}.unitProperties.resp;
resp1d=nonlin(resp1d);

% net=run_net(net,imgs1d_noface);
net=run_face_area_model3(net,imgs1d_noface,'mode',options.mode);

resp1d_noface=net.content.layers{4}.unitProperties.resp;
resp1d_noface=nonlin(resp1d_noface);

% full tuning 

smoothing=zeros(nvalue,nvalue);
for V=1:nvalue
    smoothing(V,:)=gauss(1:nvalue,V,1);
    smoothing(V,:)=smoothing(V,:)/sum(smoothing(V,:),2);
end;
% smoothing=eye(nvalue);

surr_idx=surrogate_index(len);

bmat=false(nvalue,len,nparam);
for P=1:nparam
    for V=1:nvalue
        bmat(V,:,P)=params(P,:)==values(V);
    end;
end;

tuning=zeros(nvalue,nparam,nunit);
tuning_het=zeros(1,nparam,nunit);
tuning_het_surr=zeros(len-1,nparam,nunit);
tuning_het_sp=zeros(nvalue,3,nparam,nunit);

tuning_sig=zeros(nparam,nunit);
tuning_single_sig=zeros(nparam,nunit);
tuning_single_noface_sig=zeros(nparam,nunit);

gamrnd2=@(m,v)gamrnd(v./m,m.^2./v);

fprintf('calculating full tuning...\n');
parfor_progress(nunit);
% parfor U=1:nunit
for U=1:nunit
    r=resp(:,U);
    if options.noise>0 r=gamrnd2(r,ones(size(r))*options.noise); end;
    surr=create_surrogates(r,surr_idx);
%     if options.noise>0 surr=gamrnd2(surr,ones(size(surr))*options.noise); end;
    for P=1:nparam
        tuning(:,P,U)=get_tuning(r,bmat(:,:,P),smoothing);
        het=heterogeneity(tuning(:,P,U));
        [mint,maxt,meant,het_surr]=heterogeneity_interval(surr,bmat(:,:,P),smoothing);
        tuning_het(1,P,U)=het;
        tuning_het_surr(:,P,U)=het_surr;
        tuning_het_sp(:,:,P,U)=[mint maxt meant];
    end;
    parfor_progress;
end;

for U=1:nunit
    for P=1:nparam
        tuning_sig(P,U)=tuning_significance(tuning(:,P,U),tuning_het(1,P,U),tuning_het_surr(:,P,U),size(tuning_het_surr,1)*options.conf_level/100);
    end;
end;

% 2D full tuning

smoothing2=zeros(nvalue,nvalue,nvalue,nvalue);
[ix iy]=ndgrid(1:nvalue,1:nvalue);
for V1=1:nvalue
    for V2=1:nvalue
        smoothing2(V1,V2,:,:)=gauss2(ix,iy,V1,V2,1,1);
        smoothing2(V1,V2,:,:)=smoothing2(V1,V2,:,:)/sum(flatten(smoothing2(V1,V2,:,:)));
    end;
end;
smoothing2=reshape(smoothing2,nvalue^2,nvalue^2);

bmat2=false(nvalue,nvalue,len,nparam,nparam);
for P1=1:nparam
    for P2=1:nparam
        for V1=1:nvalue
            for V2=1:nvalue
                bmat2(V1,V2,:,P1,P2)=params(P1,:)==values(V1) & params(P2,:)==values(V2);
            end;
        end;
    end;
end;
bmat2=reshape(bmat2,nvalue^2,len,nparam,nparam);

tuning2=zeros(nvalue,nvalue,nparam,nparam,nunit);

fprintf('calculating 2D full tuning...\n');
parfor_progress(nunit);
% parfor U=1:nunit
for U=1:nunit
    r=resp(:,U);
    for P1=1:nparam
        for P2=1:nparam
            tuning2(:,:,P1,P2,U)=reshape(get_tuning2(r,bmat2(:,:,P1,P2),smoothing2),nvalue,nvalue);
        end;
    end;
    parfor_progress;
end;

% 1D tuning w/ and w/o face

tuning_single=zeros(nvalue,nparam,nunit);
tuning_single_noface=zeros(nvalue,nparam,nunit);
tuning_single_het=zeros(1,nparam,nunit);
tuning_single_noface_het=zeros(1,nparam,nunit);

resp1d=reshape(resp1d,nvalue,nparam,nunit);
resp1d_noface=reshape(resp1d_noface,nvalue,nparam,nunit);

fprintf('calculating 1D tuning...\n');
for U=1:nunit
    for P=1:nparam
        tuning_single(:,P,U)=smoothing*resp1d(:,P,U);
        tuning_single_noface(:,P,U)=smoothing*resp1d_noface(:,P,U);
        tuning_single_het(1,P,U)=heterogeneity(tuning_single(:,P,U));
        tuning_single_noface_het(1,P,U)=heterogeneity(tuning_single_noface(:,P,U));
        tuning_single_sig(P,U)=tuning_significance(tuning_single(:,P,U),tuning_single_het(1,P,U),tuning_het_surr(:,P,U),size(tuning_het_surr,1)*options.conf_level/100);
        tuning_single_noface_sig(P,U)=tuning_significance(tuning_single_noface(:,P,U),tuning_single_noface_het(1,P,U),tuning_het_surr(:,P,U),size(tuning_het_surr,1)*options.conf_level/100);
    end;
end;
    
% save analysis results

net.content.layers{4}.unitProperties2.baseline=baseline;
net.content.layers{4}.unitProperties2.tuning=tuning;
net.content.layers{4}.unitProperties2.tuning_het=tuning_het;
% net.content.layers{4}.unitProperties2.tuning_het_surr=tuning_het_surr;
net.content.layers{4}.unitProperties2.tuning_het_sp=tuning_het_sp;
net.content.layers{4}.unitProperties2.tuning2=tuning2;
net.content.layers{4}.unitProperties2.tuning_single=tuning_single;
net.content.layers{4}.unitProperties2.tuning_single_het=tuning_single_het;
net.content.layers{4}.unitProperties2.tuning_single_noface=tuning_single_noface;
net.content.layers{4}.unitProperties2.tuning_single_noface_het=tuning_single_noface_het;
net.content.layers{4}.unitProperties2.tuning_sig=tuning_sig;
net.content.layers{4}.unitProperties2.tuning_single_sig=tuning_single_sig;
net.content.layers{4}.unitProperties2.tuning_single_noface_sig=tuning_single_noface_sig;
net=strip_resp(net);


end

function tuning=get_tuning(resp,bmat,smoothing)

tuning=bsxfun(@rdivide,bmat*resp,sum(bmat,2)+eps);
tuning(isnan(tuning))=eps;
tuning=smoothing*tuning;

end

function tuning=get_tuning2(resp,bmat,smoothing)

tuning=bsxfun(@rdivide,bmat*resp,sum(bmat,2)+eps);
tuning(isnan(tuning))=eps;
tuning=smoothing*tuning;

end

function [min_tuning,max_tuning,mean_tuning,het_surr]=heterogeneity_interval(surr,idxmat,smoothing)

ts=get_tuning(surr,idxmat,smoothing);
het_surr=heterogeneity(ts);

mean_tuning=mean(ts,2);
min_tuning=min(ts,[],2);
max_tuning=max(ts,[],2);

end
   
function surr=create_surrogates(resp,surr_idx)

surr=resp(surr_idx);

end

function idx=surrogate_index(len)

idx=zeros(len,len-1);
for I=1:len-1
    idx(:,I)=[I+1:len 1:I];
end;

end
            
function het=heterogeneity(tuning)

tuning=bsxfun(@rdivide,tuning,sum(tuning,1));

het=1+sum(tuning.*log(tuning),1)/log(size(tuning,1));

end

