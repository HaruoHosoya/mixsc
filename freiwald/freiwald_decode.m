function [params,cis]=freiwald_decode(net,cimgs,cparams,imgs,varargin)

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

resp=net.content.layers{4}.unitProperties.resp;
resp=nonlin(resp(:,units));

models=cell(nparam,1);

for P=1:nparam
    models{P}=fitlm(resp,cparams(P,:)');
end;

net=run_face_area_model(net,imgs,'noise_var',options.noise_var);

resp=net.content.layers{4}.unitProperties.resp;
resp=nonlin(resp(:,units));

[~,len]=size(imgs);

params=zeros(nparam,len);
cis=zeros(nparam,len,2);

for P=1:nparam
    [p,ci]=predict(models{P},resp);
    p=max(-5,min(5,p));
    params(P,:)=p';
    cis(P,:,:)=ci;
end;


end
