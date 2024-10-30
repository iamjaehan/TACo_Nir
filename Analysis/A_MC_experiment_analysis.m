close all
colorArray={[0 0.4470 0.7410],[0.8500 0.3250 0.0980],[0.9290 0.6940 0.1250],[0.4660 0.6740 0.1880]};

% data = load("[0]_Experiment_set7_1.mat");
data = load("[0]_Experiment_set8_1.mat");

optGap = cell2mat(data.OptGap);
count = cell2mat(data.Count);
fairness = cell2mat(data.Fairness);

% xtickLabelSet = {'TAC (0.1xstep)','TAC (ours)','TAC (10xstep)','TAC (int @ 60)', 'TAC (int @ 30)',...
%     '5%','10%','TAC (int @ 5)','Voting', 'Utilitarian', 'Egalitarian', 'Random Demo'};  

xtickLabelSet = {'TAC (0.1xstep)','TAC (ours)','TAC (10xstep)','TAC (int @ 60)', 'TAC (int @ 30)',...
    'TAC (int @ 5)','Voting', 'Utilitarian', 'Egalitarian', 'Random Demo'};  

%% param
whiskerVal = 10;
fontsize = 25;

%% Experiment #1: Optgap comparison
% kernel = [2,9,10,11,12];
kernel = [2,7,8,9,10];
figure(1)
clf
h=boxplot(optGap(kernel,:)','Notch','on','Whisker',whiskerVal);
localxtickLabelSet = xtickLabelSet(kernel);
xticklabels(localxtickLabelSet);

a = get(gca,'XTickLabel');
set(gca,'XTickLabel',a,'FontName','Times','fontsize',18)
% xlabel("Algorithm",'FontName','Times','FontSize',18)
ylabel("Optimality gap",'FontName','Times','FontSize',18)
% title("Monte-Carlo test (4-player)","FontName",'Times','FontSize',18)
set(gca,'XTickLabel',a,'FontName','Times','fontsize',fontsize,'FontWeight','normal')
set(gcf,'Position',[500, 500 1200 500])
set(h,{'linew'},{2})
ylim([0 inf])
grid on

exportgraphics(gca,"Figure/"+"Exp1_optgap.png")

%% Experiment #2: Convergence
figure(2)
% kernel = [2,9,10,11,12];
kernel = [2,7,8,9,10];
clf
h=boxplot(count(kernel,:)','Notch','on','Whisker',whiskerVal);
localxtickLabelSet = xtickLabelSet(kernel);
xticklabels(localxtickLabelSet);

a = get(gca,'XTickLabel');
% xlabel("Algorithm",'FontName','Times')
ylabel("Number of rounds",'FontName','Times')
% title("Monte-Carlo test (4-player)","FontName",'Times')
set(gca,'XTickLabel',a,'FontName','Times','fontsize',fontsize,'FontWeight','normal')
set(gcf,'Position',[500, 500 1200 500])
set(h,{'linew'},{2})
ylim([0 inf])
grid on

exportgraphics(gca,"Figure/"+"Exp2_convergence.png")

%% Experiment #3: Fairness
figure(3)
% kernel = [2,9,10,11,12];
kernel = [2,7,8,9,10];
clf
h=boxplot(fairness(kernel,:)','Notch','on','Whisker',whiskerVal);
localxtickLabelSet = xtickLabelSet(kernel);
xticklabels(localxtickLabelSet);

a = get(gca,'XTickLabel');
set(gca,'XTickLabel',a,'FontName','Times','fontsize',18)
% xlabel("Algorithm",'FontName','Times','FontSize',18)
ylabel("Gini index",'FontName','Times','FontSize',18)
% title("Monte-Carlo test (4-player)","FontName",'Times','FontSize',18)
set(gca,'XTickLabel',a,'FontName','Times','fontsize',fontsize,'FontWeight','normal')
set(gcf,'Position',[500, 500 1200 500])
set(h,{'linew'},{2})
ylim([0 inf])
grid on

exportgraphics(gca,"Figure/"+"Exp3_gini.png")

%% Experiment #4: Trading step
kernel = [1,2,3];
offset = linspace(-0.15,0.15,2);
boxWidth = 0.25;
xtickPos = 1:length(kernel);

figure(4)
clf

yyaxis left
h1=boxplot(fairness(kernel,:)','Notch','on','Whisker',whiskerVal,'Positions',xtickPos'+offset(1),'Widths',boxWidth ...
    ,'Colors',colorArray{1});
set(h1,{'linew'},{2})
hold on

localxtickLabelSet = xtickLabelSet(kernel);
xticklabels(localxtickLabelSet);

a = get(gca,'XTickLabel');
set(gca,'XTickLabel',a,'FontName','Times','fontsize',18)
ylabel("Gini index",'FontName','Times','FontSize',18,'Color',colorArray{1})
ylim([0 inf])

yyaxis right
h2=boxplot(optGap(kernel,:)','Notch','on','Whisker',whiskerVal,'Positions',xtickPos'+offset(2),'Widths',boxWidth ...
    ,'Colors',colorArray{2});
set(h2,{'linew'},{2})
ylabel("Optimality gap",'FontName','Times','FontSize',18,'Color',colorArray{2})

set(gca,'XTickLabel',a,'FontName','Times','fontsize',fontsize,'FontWeight','normal')
set(gcf,'Position',[500, 500 1200 500])
ylim([0 inf])
grid on

exportgraphics(gca,"Figure/"+"Exp4_1_interruption.png")

%% Experiment #4_2: Trading step
kernel = [1,2,3];

figure(44)
h=boxplot(count(kernel,:)','Notch','on','Whisker',whiskerVal,'Widths',boxWidth);
localxtickLabelSet = xtickLabelSet(kernel);
xticklabels(localxtickLabelSet);

a = get(gca,'XTickLabel');
set(gca,'XTickLabel',a,'FontName','Times','fontsize',18)
% xlabel("Algorithm",'FontName','Times','FontSize',18)
ylabel("Number of rounds",'FontName','Times','FontSize',18)
% title("Monte-Carlo test (4-player)","FontName",'Times','FontSize',18)
set(gca,'XTickLabel',a,'FontName','Times','fontsize',fontsize,'FontWeight','normal')
set(gcf,'Position',[500, 500 1200 500])
set(h,{'linew'},{2})
ylim([0 inf])
grid on

exportgraphics(gca,"Figure/"+"Exp4_2_interruption.png")

%% Experiment #5: Interrupt
% kernel = [2,4,5,8];
kernel = [2,4,5,6];
offset = linspace(-0.15,0.15,2);
boxWidth = 0.25;
xtickPos = 1:length(kernel);

figure(5)
clf

yyaxis left
h1=boxplot(fairness(kernel,:)','Notch','on','Whisker',whiskerVal,'Positions',xtickPos'+offset(1),'Widths',boxWidth ...
    ,'Colors',colorArray{1});
set(h1,{'linew'},{2})
hold on

localxtickLabelSet = xtickLabelSet(kernel);
xticklabels(localxtickLabelSet);
ylim([0 inf])

a = get(gca,'XTickLabel');
set(gca,'XTickLabel',a,'FontName','Times','fontsize',18)
ylabel("Gini index",'FontName','Times','FontSize',18,'Color',colorArray{1})

yyaxis right
h2=boxplot(optGap(kernel,:)','Notch','on','Whisker',whiskerVal,'Positions',xtickPos'+offset(2),'Widths',boxWidth ...
    ,'Colors',colorArray{2});
set(h2,{'linew'},{2})
ylabel("Optimality gap",'FontName','Times','FontSize',18,'Color',colorArray{2})

set(gca,'XTickLabel',a,'FontName','Times','fontsize',fontsize,'FontWeight','normal')
set(gcf,'Position',[500, 500 1200 500])
ylim([0 inf])
grid on

exportgraphics(gca,"Figure/"+"Exp5_1_interruption.png")

%% Experiment #5_2: Interrupt
figure(55)
% kernel = [2,4,5,8];
kernel = [2,4,5,6];
clf
h=boxplot(count(kernel,:)','Notch','on','Whisker',whiskerVal,'Widths',boxWidth);
localxtickLabelSet = xtickLabelSet(kernel);
xticklabels(localxtickLabelSet);

a = get(gca,'XTickLabel');
set(gca,'XTickLabel',a,'FontName','Times','fontsize',18)
% xlabel("Algorithm",'FontName','Times','FontSize',18)
ylabel("Number of rounds",'FontName','Times','FontSize',18)
% title("Monte-Carlo test (4-player)","FontName",'Times','FontSize',18)
set(gca,'XTickLabel',a,'FontName','Times','fontsize',fontsize,'FontWeight','normal')
set(gcf,'Position',[500, 500 1200 500])
set(h,{'linew'},{2})
ylim([0 inf])
grid on

exportgraphics(gca,"Figure/"+"Exp5_2_interruption.png")
