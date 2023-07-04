function [train,train_params]=freiwald_face_dataset(wid,len)

[train,train_params]=freiwald_random_face_images(256,6:19,len);
train=train(89:end-40,65:end-64,:);
train=imresize_all(train,[wid wid]);
train=reshape(train,wid^2,size(train,3));

% [test,test_params]=cartoon_test_face_images(256,6:19);
% test=test(89:end-40,65:end-64,:);
% test=imresize_all(test,[wid wid]);
% test=reshape(test,wid^2,size(test,3));

end

