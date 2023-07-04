function [imgs,masks]=freiwald_partial_faces(sz)

nmask=7;
imgs=zeros(sz,sz,2^nmask);
param=[3 -3 0 3 2 0 0 5 0 5 5 5 0 -2 5 0 3 0 5];

masks=~logical(dec2bin(0:2^nmask-1)=='1')';

for I=1:2^nmask
    imgs(:,:,I)=cartoonStimuli(param,sz,false,masks(:,I));
end

end






