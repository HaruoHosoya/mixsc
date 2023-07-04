function raw_face_image_ica_demo(ndata)

[indim,len]=size(ndata);
wid=sqrt(indim);
NN=[10000 2000 425];
rdim=200;

figure;
for I=1:3
    N=NN(I);
    [Y,A,W]=fastica(ndata(:,randperm(len,N)),'approach','symm','g','tanh','lastEig',rdim);
    subplot(1,3,I);
    s=std(A(:));
    montage(reshape(A(:,1:25),wid,wid,1,25),[-2*s 2*s]);
    title(sprintf('ica (D=%d N=%d)',rdim,N));
end;

end
