function net=set_signal_sd(net,fdata,odata,varargin)

pr=inputParser;
pr.addParamValue('mode','sc',@isstr);

pr.parse(varargin{:});
options=pr.Results;

layer=net.content.layers{4};

basis=layer.basis;
basis=reshape(basis,size(basis,1),size(basis,3));
nunits=size(basis,2);
funit=layer.face_selective;
ounit=setdiff(1:nunits,funit);

net=run_face_area_model3(net,fdata,'mode',options.mode,'ignore_signal_sd',true);

resp=net.content.layers{4}.unitProperties.resp;
sf=std(resp(:,funit),[],1);

net=run_face_area_model3(net,odata,'mode',options.mode,'ignore_signal_sd',true);

resp=net.content.layers{4}.unitProperties.resp;
so=std(resp(:,ounit),[],1);

s=[sf so];

net.content.layers{4}.unitProperties.signal_sd=s;
net=strip_resp(net);

end

