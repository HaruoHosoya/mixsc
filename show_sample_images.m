figure('position',[100 900 400 400]);
imagesc(filt);
colorbar;
axis image;

figure('position',[100 50 1200 1200]);
montage(reshape(ndata(:,1:36),64,64,1,36),[-2 2])

figure('position',[400 50 1200 1200]);
montage(reshape(odata(:,1:36),64,64,1,36),[-2 2])

figure('position',[1700 50 1200 1200]);
montage(reshape(cdata(:,1:36),64,64,1,36),[-2 2])

figure('position',[1000 50 1200 1200]);
montage(reshape(cdata1d(:,:),64,64,1,209),[-2 2],'size',[19 11])

figure('position',[800 50 1200 1200]);
montage(reshape(cdata1d_noface(:,:),64,64,1,209),[-2 2],'size',[19 11])

figure('position',[600 50 1200 1200]);
montage(reshape(cdatap(:,:),64,64,1,128),[-2 2])

figure('position',[1200 50 1200 1200]);
montage(reshape(hdata(:,1:64),64,64,1,64),[-2 2])
