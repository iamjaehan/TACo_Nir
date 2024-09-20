%1
%2 - interrupt value 바꿈
%3 - increment 적용
%4 - multiply decrement 적용
%5 - trade 용량 적용 - test (30 trials)
%6 - Total set test (100 trials)
% data = load("[0]_Experiment_set1.mat");
data = load("[0]_Experiment_set7_1.mat");

optGap = cell2mat(data.OptGap);
count = cell2mat(data.Count);
fairness = cell2mat(data.Fairness);

xtickLabelSet = {'Auction (step 1)','Auction (step 10)','Auction (step 100)','Auction (int 60)', 'Auction (int 30)', 'Auction (int n+1)',...
    '5%','10%','Voting', 'System Optimal', 'System Fair', 'Random Demo'};

%% param
whiskerVal = 1;

%% Experiment #1: Optgap comparison
figure(1)
clf
boxplot(optGap','Whisker',whiskerVal)
xticklabels(xtickLabelSet)

a = get(gca,'XTickLabel');
set(gca,'XTickLabel',a,'FontName','Times','fontsize',18)
xlabel("Algorithm",'FontName','Times','FontSize',18)
ylabel("Optimality gap",'FontName','Times','FontSize',18)
title("Monte-Carlo test (4-player)","FontName",'Times','FontSize',18)
ylim([0 inf])
grid on

%% Experiment #2: Convergence
figure(2)
clf
boxplot(count','Whisker',whiskerVal)
xticklabels(xtickLabelSet)

a = get(gca,'XTickLabel');
set(gca,'XTickLabel',a,'FontName','Times','fontsize',18)
xlabel("Algorithm",'FontName','Times','FontSize',18)
ylabel("Number of rounds",'FontName','Times','FontSize',18)
title("Monte-Carlo test (4-player)","FontName",'Times','FontSize',18)
ylim([0 inf])
grid on

%% Experiment #3: Fairness
figure(3)
clf
boxplot(fairness','Whisker',whiskerVal)
xticklabels(xtickLabelSet)

a = get(gca,'XTickLabel');
set(gca,'XTickLabel',a,'FontName','Times','fontsize',18)
xlabel("Algorithm",'FontName','Times','FontSize',18)
ylabel("Gini index",'FontName','Times','FontSize',18)
title("Monte-Carlo test (4-player)","FontName",'Times','FontSize',18)
ylim([0 inf])
grid on

%% Experiment #4: Interrupt effect


%% Experiment #5: Trade-off

