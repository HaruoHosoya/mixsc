function rand_weights_demo(g_rad,m_rad,n)

ix=-g_rad*10:g_rad*10;
g=gauss(ix,0,g_rad);

m=zeros(m_rad*2+1,n);
for I=1:n
    x=rand(g_rad*20+1,1)*2-1;
    y=conv(x,g,'same');
    m(:,I)=y(g_rad*10-m_rad:g_rad*10+m_rad);
    m(:,I)=m(:,I)-mean(m(:,I));
    m(:,I)=m(:,I)/abs(max(m(:,I)));
end;

figure;
[~,maxi]=max(m,[],1);
[~,idx]=sort(maxi,'ascend');
h=hist(maxi,11);
rli=(h(1)+h(11))/2/sum(h(2:10))*9;

subplot(1,2,1);
imagesc(m(:,idx)');

subplot(1,2,2);
bar(h);
title(sprintf('%f',rli));

end

    