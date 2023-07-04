function prob_face=show_face_probability(net,data,varargin)

pr=inputParser;
pr.addParamValue('display',false,@islogical);
pr.addParamValue('face_selective',NaN,@isnumeric);
pr.addParamValue('linear',false,@islogical);
pr.addParamValue('mode','mix',@isstr);
pr.parse(varargin{:});
options=pr.Results;

if options.linear
    nonlin=@(x)x;
else
%     nonlin=@(x)max(x,0);
    nonlin=@smooth_half_rect;
end;

if ~iscell(data) data={data}; end;

figure;
for I=1:length(data)
    net=run_face_area_model3(net,data{I},'mode',options.mode);
%     resp=nonlin(net.content.layers{4}.unitProperties.resp);
    prob_face{I}=net.content.layers{4}.unitProperties.prob_face;
    histogram(prob_face{I},0:0.05:1,'normalization','probability'); hold on;
    xlim([-0.1 1.1]);
    xlabel('face probability');
    ylabel('# of images (%)');
    set(gca,'FontName','Times','FontSize',12);
end;
set(gca,'YTickLabel',get(gca,'YTick')*100);

end


