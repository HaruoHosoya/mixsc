function best_responsive_stimuli(net,stimimgs,layer,node,units,varargin)

pr=inputParser;
pr.addParamValue('numtoshow',5,@isnumeric);
pr.addParamValue('pos',NaN,@isnumeric);
pr.addParamValue('showworst',false,@islogical);
pr.addParamValue('numtoaverage',100,@isnumeric);
pr.addParamValue('entire',true,@islogical);
pr.addParamValue('showactivity',true,@islogical);
pr.addParamValue('resp',NaN,@isnumeric);
pr.parse(varargin{:});
pr=pr.Results;

net=calc_coverage(net);
l=net.content.layers{layer};
resp=l.unitProperties.resp;
cov=l.nodeProperties.cover;

nunits=length(units);

p=1;
if pr.showworst
    px=pr.numtoshow*2+4;
else
    px=pr.numtoshow+3;
end;
py=nunits;

if ~isnan(pr.resp)
    resp=pr.resp;
end;
   

for I=1:nunits
    unit=units(I);
    r=resp(:,unit,node);
    r(isnan(r))=0;
    c=cov(node,:);
    [~,idx]=sort(r,'descend');
    if pr.showworst
        nums=[1:pr.numtoshow length(idx)-pr.numtoshow+1:length(idx)];
    else
        nums=[1:pr.numtoshow];
    end;
    subplot(py,px,p); p=p+1;
    text(0.5,0.5,sprintf('(%d,%d)',node,unit)); axis off;
    for J=1:length(nums)
        subplot(py,px,p); p=p+1;
        st=stimimgs(:,:,idx(nums(J)));
        if pr.entire
            imagesc(st); colormap(gray); axis image; axis off;
            hold on; line([c(1) c(1)+c(3) c(1)+c(3) c(1) c(1)],[c(2) c(2) c(2)+c(4) c(2)+c(4) c(2)],'Color','red');
        else
            imagesc(st(c(2):c(2)+c(4)-1,c(1):c(1)+c(3)-1)); colormap(gray); axis image; axis off;
        end;
        if pr.showactivity
            if ~isnan(pr.pos)
                title(sprintf('%1.3f / m%d',r(idx(nums(J))),pr.pos(idx(nums(J)),4)));
            else
                title(sprintf('%1.3f',r(idx(nums(J)))));
            end;
        end;
    end;
    
    subplot(py,px,p); p=p+1;
    r2=r;
%     r2=log(2*exp(r)-1); r2(isinf(r2))=0;
    ave=sum(bsxfun(@times,stimimgs(:,:,idx([1:pr.numtoaverage end-pr.numtoaverage:end])),shiftdim(r2(idx([1:pr.numtoaverage end-pr.numtoaverage:end])),-2)),3);
    imagesc(ave(c(2):c(2)+c(4)-1,c(1):c(1)+c(3)-1)); colormap(gray); axis image; axis off;
    
%     subplot(py,px,p); 
    p=p+1;
%     stimimgs2=stimimgs(c(2):c(2)+c(4)-1,c(1):c(1)+c(3)-1,:);
%     st2=bsxfun(@times,stimimgs2(:,:,idx(1:pr.numtoaverage)),shiftdim(r2(idx(1:pr.numtoaverage)),-2));
% %     st2=stimimgs2(:,:,idx(1:pr.numtoaverage));
%     t=pca(reshape(st2,c(4)*c(3),pr.numtoaverage)','NumComponents',1,'Algorithm','eig');
%     imagesc(reshape(t,c(4),c(3))); colormap(gray); axis image; axis off;
    
    if pr.showworst
        subplot(py,px,p); p=p+1;
        st2=bsxfun(@times,stimimgs(:,:,idx(end-pr.numtoaverage+1:end)),shiftdim(r2(idx(end-pr.numtoaverage+1:end)),-2));
%         st2=stimimgs2(:,:,idx(end-pr.numtoaverage+1:end));
        t=pca(reshape(st2,c(4)*c(3),pr.numtoaverage)','NumComponents',1,'Algorithm','eig');
        imagesc(reshape(t,c(4),c(3))); colormap(gray); axis image; axis off;
    end;
    
%     p=p+1;
%     for J=1:1
%         subplot(nunits,num+1+1,p); p=p+1;
%         sa=mean(samples(:,:,unit,node),2);
%         wd=floor(sqrt(length(sa))); ht=floor(length(sa)/wd);
%         sa=reshape(sa,wd,ht);
%         imagesc(sa'); colormap(gray); axis image; 
%     end;
    
end;

end

