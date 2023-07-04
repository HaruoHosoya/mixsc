function params=freiwald_decode2(net,cimgs,cparams,imgs,varargin)

pr=inputParser;
pr.addParamValue('noise_var',NaN,@isnumeric);
pr.addParamValue('units',NaN,@isnumeric);
pr.parse(varargin{:});
options=pr.Results;

v2info=net.structure.layers{4};
nunit=v2info.numUnits;
nonlin=@smooth_half_rect;

if isnan(options.units)
    units=1:nunit;
else
    units=options.units;
end;

% responses to cartoon face stimuli

nparam=19;
nvalue=11;
values=-5:5;

[~,len]=size(cimgs);
% net=run_net(net,imgs);
net=run_face_area_model(net,cimgs,'noise_var',options.noise_var);

resp1=net.content.layers{4}.unitProperties.resp;
resp1=nonlin(resp1(:,units));

net=run_face_area_model(net,imgs,'noise_var',options.noise_var);

resp2=net.content.layers{4}.unitProperties.resp;
resp2=nonlin(resp2(:,units));

[~,len]=size(imgs);

params=zeros(nparam,len);

for I=1:len
    dist=sum(bsxfun(@minus,resp2(I,:),resp1).^2,2);
    [~,mini]=min(dist);
    params(:,I)=cparams(:,mini);
end;


end
