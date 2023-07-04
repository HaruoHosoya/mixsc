function freiwald_show_test_responses(YY,A,W,tim)

[nunits,d]=size(W);

% tim=reshape(test_face_images(128,[4 5 14 15 17]),128,128,11*5);
% tim=reshape(test_face_images(128,[4 6 9 14 17]),128,128,11*5);
% tim=imresize_all(tim,[50 50]);
imwid=sqrt(size(tim,1));
nparam=size(tim,2)/11;
wid=ceil(sqrt(nparam));
hit=ceil(nparam/wid);

resp=reshape(W*tim,nunits,11*nparam);
resp=bsxfun(@minus,resp,mean(resp,2));
resp=bsxfun(@rdivide,resp,max(resp,[],2));
resp=reshape(resp,nunits,11,nparam);

h1=figure;
h2=figure;


for I=1:nparam
    figure(h1);subplot(hit,wid,I);
    r=resp(:,:,I);
    idx=find(max(r,[],2)>max(r(:))*0.2);
    if length(idx(:))<=1 continue; end;
    r=r(idx,:);
    [~,maxi]=max(r,[],2);
    [~,idx]=sort(maxi,'ascend');
    m=max(flatten(r(idx,:)));
    imagesc(r(idx,:),[-m m]);
    
    figure(h2);subplot(hit,wid,I);
    hist(maxi,1:11);
    v=sum(maxi==1|maxi==11)/2/sum(maxi>1&maxi<11)*9;
    title(sprintf('%1.3f',v));
%     bar(sum(bsxfun(@eq,r,max(r,[],2))));
    xlim([0.5 11.5]);
end;

h3=figure;
h4=figure;
wid=ceil(sqrt(nunits));
hit=ceil(nunits/wid);

figure(h3);
m=std(A(:));
montage(reshape(A,imwid,imwid,1,size(A,2)),[-m*3 m*3])

figure(h4);
for I=1:nunits
    subplot(hit,wid,I);
    m=max(flatten(resp(I,:,:)));
    imagesc(reshape(resp(I,:,:),11,14),[-m m]);
end;


figure;
for I=1:nunits
    subplot(hit,wid,I);
    hist(YY(I,:)',20);
    xlim([min(YY(I,:)'),max(YY(I,:)')]);
end;

end

