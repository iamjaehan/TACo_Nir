% data = load("MC_5p.mat");
data = load("MC_faster_iteration.mat");
% data = load("[1] MC_tradeNum_tradeoff.mat");


%%%
% data = load("MC_private_public.mat");
% fair_pub = data.Fair_pub;
% fair_pri = data.Fair_pri;
% fair_pub = cell2mat(fair_pub);
% fair_pri = cell2mat(fair_pri);
% figure(5)
% clf
% boxplot([fair_pub;fair_pri]','Whisker',2)
% xticklabels({'Public','Revenue + Public cost'})
% a = get(gca,'XTickLabel');
% set(gca,'XTickLabel',a,'FontName','Times','fontsize',18)
% grid on
% ylabel("Gini index",'FontName','Times','FontSize',18)
% title("Monte-Carlo test (4-player)","FontName",'Times','FontSize',18)
% ylim([0 inf])
% xlabel("Fairness type",'FontName','Times','FontSize',18)
% saveas(gcf,"Fairness.png")
%%%

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
% xticklabels({'Auction','Voting','Auction w/ privacy'})
% xticklabels({'0.1','1','10','100','1000'})
xticklabels({'Top1 comm.','Top3 comm.','Top5 comm.'})
a = get(gca,'XTickLabel');
set(gca,'XTickLabel',a,'FontName','Times','fontsize',18)
grid on
ylabel("Optimality gap",'FontName','Times','FontSize',18)
title("Monte-Carlo test (4-player)","FontName",'Times','FontSize',18)
ylim([0 inf])
% xlabel("Step size",'FontName','Times','FontSize',18)
xlabel("Number of comm. channel",'FontName','Times','FontSize',18)
saveas(gcf,"StepSize_OptimalityGap.png")


figure(3)
clf
boxplot(count','Whisker',2)
xticklabels({'Auction','Voting'})
xticklabels({'Auction','Voting','Auction w/ privacy'})
% xticklabels({'0.1','1','10','100','1000'})
xticklabels({'Top1 comm.','Top3 comm.','Top5 comm.'})
a = get(gca,'XTickLabel');
set(gca,'XTickLabel',a,'FontName','Times','fontsize',18)
grid on
ylabel("Iteration Steps",'FontName','Times','FontSize',18)
title("Monte-Carlo test (4-player) - Convergence","FontName",'Times','FontSize',18)
ylim([0 inf])
% xlabel("Step size",'FontName','Times','FontSize',18)
xlabel("Number of comm. channel",'FontName','Times','FontSize',18)
saveas(gcf,"StepSize_IterationSteps.png")

figure(4)
clf
ss = size(data);
% ll = 1:ss(1); ll=ll';
ll = -1:3; ll = ll';
ID = [];
for i = 1:ss(2)
    ID= horzcat(ID,ll);
end

delIdx = find(count < 1000);
data = data(delIdx);
count = count(delIdx);
ID = ID(delIdx);

scatter(data(:),count(:),50,ID(:))
grid on
xlabel("Optimality gap",'FontName',"Times",'FontSize',18)
ylabel("Iteration Steps",'FontName',"Times",'FontSize',18)
colormap("jet")
colorbar()
title("Tradeoff relationship","FontName",'Times','FontSize',18)
saveas(gcf,"OptimalityGap_IterationSteps_tradeoff.png")