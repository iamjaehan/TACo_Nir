data = load("[0]HistTest.mat");
data.costHist;
costHist = data.costHist;
payHist = data.payHist;
offerHist = data.offerHist;
priceHist = data.priceHist;
cycleSizeHist = data.cycleSizeTrack;

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
plot(rec(4,:,t1),rec(4,:,t2),'go--')
axis equal

%% diff reduction
m = 24; n = 4; d=10; gamma=0.8; adjust = 1.2; epsilon = 10;

limit = (m+1)*(n-1)*d*adjust;
l = length(data.cycleSizeTrack);
rec = zeros(l,1);
limitRec = zeros(l,1);
limit2Rec = zeros(l,1);

for i = 1:l
    rec(i) = data.cycleSizeTrack{i};
    limitRec(i) = limit*gamma^(i-1);
    limit2Rec(i) = (data.activeTrack{i}+1)*(n-1)*d*gamma^(i-1)*adjust;
end

figure(4)
clf
plot(rec,'LineWidth',3)
hold on
plot(limitRec,'LineWidth',2,'LineStyle','--')
plot(limit2Rec,'LineWidth',2,'LineStyle',':')
plot([1 l],[epsilon epsilon],'k:')
grid on
xlabel("Number of cycles")
ylabel("Max price difference")

%%
% data = load("Analysis/[0]_Experiment_cycleSize.mat");
data = load("Analysis/[0]_Experiment_epsilon.mat");
l = length(data.cycleSizeTrackList);
maxL = 7;
out = [];

count = 0;
for i = 1:l
    localDat = data.cycleSizeTrackList{i};
    ll = length(localDat);
    for j = 1:ll
        count = count + 1;
        out(count,:) = [j,localDat{j}];
    end
end

m = 24; n = 4; d=10; gamma=0.8; adjust = 1.2; epsilon = 10;
limit = (m+1)*(n-1)*d;
rec = zeros(l,1);
limitRec = zeros(maxL,1);

for i = 1:maxL
    limitRec(i) = limit*gamma^(i-1);
end

figure(5)
clf
plot(out(:,1),out(:,2),'o','MarkerSize',5,'LineWidth',5)
hold on
plot(limitRec)
grid on
xlabel("Number of cycles")
ylabel("Max price difference")