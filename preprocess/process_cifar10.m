function [trainImages,trainLabels,testImages,testLabels]=process_cifar10

pwd=cd;
cd('~/datasets/cifar-10-batches-mat');

b1=load('data_batch_1.mat');
b2=load('data_batch_2.mat');
b3=load('data_batch_3.mat');
b4=load('data_batch_4.mat');
b5=load('data_batch_5.mat');
bt=load('test_batch.mat');

trainImages=cat(1,b1.data,b2.data,b3.data,b4.data,b5.data)';
trainLabels=cat(1,b1.labels,b2.labels,b3.labels,b4.labels,b5.labels);
trainImages=color2gray(trainImages);
trainLabels=double(trainLabels);

testImages=bt.data';
testLabels=bt.labels;
testImages=color2gray(testImages);
testLabels=double(testLabels);

cd(pwd);

end

function gimgs=color2gray(cimgs)

[datadim,datalen]=size(cimgs);
wid=sqrt(datadim/3);
cimgs=reshape(cimgs,wid,wid,3,datalen);
gimgs=zeros(wid,wid,datalen);

for I=1:datalen
    gimgs(:,:,I)=rgb2gray(cimgs(:,:,:,I))';
end;

gimgs=reshape(gimgs,wid^2,datalen);

end

    
    
