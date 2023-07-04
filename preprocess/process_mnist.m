function [mnistTrainImages,mnistTrainLabels,mnistTestImages,mnistTestLabels]=process_mnist

pwd=cd;
cd('~/datasets/MNIST/mnistHelper/');

mnistTrainImages=loadMNISTImages('../train-images.idx3-ubyte');
mnistTrainLabels=loadMNISTLabels('../train-labels.idx1-ubyte');
mnistTestImages=loadMNISTImages('../t10k-images.idx3-ubyte');
mnistTestLabels=loadMNISTLabels('../t10k-labels.idx1-ubyte');

cd(pwd);

end
