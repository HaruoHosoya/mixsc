function show_resp_dist(net,units)

% net=run_net(net,data);
resp=squeeze(net.content.layers{4}.unitProperties.resp);

wid=ceil(sqrt(length(units)));
hit=ceil(length(units)/wid);

figure;
for I=1:length(units)
    subplot(hit,wid,I);
    m=mean(resp(:,units(I)));
    s=std(resp(:,units(I)));
    hist(resp(:,units(I)),40);
    xlim([-5 5]);
%     xlim([m+s*2 max(resp(:,units(I)))]);
end;

figure;
subplot(2,2,1);
scatter(skewness(resp),kurtosis(resp)-3);
xlim([0 5]);
ylim([0 50]);
xlabel('skewness');
ylabel('kurtosis');

subplot(2,2,2);
hist(kurtosis(resp)-3,0:1:50);
xlabel('kurtosis');
xlim([-1 50]);

subplot(2,2,3);
hist(skewness(resp),-5:0.1:5);
% hist(var(resp),40);
xlabel('skewness');
xlim([-5 5]);

end

