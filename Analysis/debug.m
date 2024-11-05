data = load("[0]HistTest.mat");
data.costHist;
costHist = data.costHist;
payHist = data.payHist;
offerHist = data.offerHist;
priceHist = data.priceHist;

dataLen = length(payHist);

player = mod(0:dataLen-2,4)+1;
whoPayWhat = zeros(dataLen-1,2);
for i = 1:dataLen-1
    idx = find(payHist{i+1} - payHist{i});
    [a,b] = ind2sub([4,24],idx);
    whoPayWhat(i,:) = [a,b];
end

out = [player',whoPayWhat];

sample = whoPayWhat(:,:);
b = sample(find(sample(:,1)~=0),:);

figure(1)
clf
histogram(b(:,2))

figure(2)
clf
plot(whoPayWhat(:,2))


%% for 2 choice case

pIdx = 1;
rec = zeros(4,dataLen,2);

t1 = 21; %for 131
t2 = 22;
% t1 = 9;
% t2 = 11;
l = 300;

for n = 1:4
    for t = 1:dataLen
        rec(n,t,[t1,t2]) = priceHist{t}(n,[t1,t2]);
    end
end

Init = priceHist{1}(:,[t1, t2]);
Last = priceHist{end}(:,[t1, t2]);

figure(3)
clf
plot([-l l], [-l l], 'k:')
hold on
for n = 1:4
    plot(Init(n,1),Init(n,2),'x','MarkerSize',15,'LineWidth',3)
    plot(Last(n,1),Last(n,2),'^','MarkerSize',15,'LineWidth',3)
end
plot(rec(1,:,t1),rec(1,:,t2),'bo--')
plot(rec(2,:,t1),rec(2,:,t2),'ro--')
plot(rec(3,:,t1),rec(3,:,t2),'mo--')
plot(rec(4,:,t1),rec(4,:,t2),'go--')3
axis equal