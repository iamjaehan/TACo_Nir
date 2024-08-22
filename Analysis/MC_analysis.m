data = load("MC_5p.mat");
count = data.Count;

data = data.Record;
data = cell2mat(data);

count = cell2mat(count);

avgVal = mean(data');
stdVal = std(data');

figure(2)
clf
boxplot(data','Whisker',2)
xticklabels({'Auction','Voting'})
xticklabels({'Auction','Voting','Auction w/ privacy'})
a = get(gca,'XTickLabel');
set(gca,'XTickLabel',a,'FontName','Times','fontsize',18)
grid on
ylabel("Optimality gap",'FontName','Times','FontSize',18)
title("Monte-Carlo test (4-player)","FontName",'Times','FontSize',18)
ylim([0 inf])

saveas(gcf,"resultPlot.png")


figure(3)
clf
boxplot(count','Whisker',2)
xticklabels({'Auction','Voting'})
xticklabels({'Auction','Voting','Auction w/ privacy'})
a = get(gca,'XTickLabel');
set(gca,'XTickLabel',a,'FontName','Times','fontsize',18)
grid on
ylabel("Iteration Steps",'FontName','Times','FontSize',18)
title("Monte-Carlo test (4-player) - Convergence","FontName",'Times','FontSize',18)
ylim([0 inf])

saveas(gcf,"resultPlot.png")