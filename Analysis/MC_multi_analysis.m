data1 = load("MC.mat");
count1 = data1.Count;

data2 = load("MC_update.mat");
count2 = data2.Count;

data3 = load("MC_3p.mat");
count3 = data3.Count;

data1 = data1.Record;
data1 = cell2mat(data1);

data2 = data2.Record;
data2 = cell2mat(data2);

data3 = data3.Record;
data3 = cell2mat(data3);

count1 = cell2mat(count1);
count2 = cell2mat(count2);
count3 = cell2mat(count3);

data = [data1;data2;data3];
count = [count1;count2;count3];

% Filter
data = data([1 3 4 5],:);
count = count([1 3 4 5],:);

figure(2)
clf
boxplot(data','Whisker',2)
xticklabels({'Auction','Voting'})
% xticklabels({'Auction','Voting','Auction w/ privacy','Range Auction','range Auction w/ P'})
% xticklabels({'Auction','Auction w/ privacy','Range Auction','range Auction w/ P'})
xticklabels({'Auction','Voting','Auction w/ privacy'})
xticklabels({'Auction','Auction w/ privacy','Range Auction','Range Auction w/ P'})
a = get(gca,'XTickLabel');
set(gca,'XTickLabel',a,'FontName','Times','fontsize',18)
grid on
ylabel("Optimality gap",'FontName','Times','FontSize',18)
title("Monte-Carlo test (4-player)","FontName",'Times','FontSize',18)
ylim([0 inf])

saveas(gcf,"OptGapPlot_range.png")


figure(3)
clf
boxplot(count','Whisker',2)
xticklabels({'Auction','Voting'})
xticklabels({'Auction','Voting','Auction w/ privacy','Range Auction','range Auction w/ P'})
xticklabels({'Auction','Auction w/ privacy','Range Auction','range Auction w/ P'})
xticklabels({'Auction','Voting','Auction w/ privacy'})
xticklabels({'Auction','Auction w/ privacy','Range Auction','range Auction w/ P'})
a = get(gca,'XTickLabel');
set(gca,'XTickLabel',a,'FontName','Times','fontsize',18)
grid on
ylabel("Iteration Steps",'FontName','Times','FontSize',18)
title("Monte-Carlo test (4-player) - Convergence","FontName",'Times','FontSize',18)
ylim([0 inf])

saveas(gcf,"Convergence_range.png")