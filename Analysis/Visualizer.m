run = [0, 1];

if run(1) == 1

e = [5.533302853313628, 19.969694952128847, 26.474627505268337, 21.932874876455383];
a = [[24.244414606129297], [-10.191976856356955], [-6.6969097486208105], [-22.155156617468116]];
% a = [[23.734287856301144], [-0.7021039579114551], [-17.207036184268226], [-22.665283379958368]];
psi = [7.934182678311471, 6.768697284003787, 5.537499075510603, 3.894762663601763]/10;

% e = [26.236422354804127, 3.023427286862066];
% a = [[-31.83887720775231], [1.3741178626749007]];
% psi = [0.1130053450961288, 2.6183804189737234];

datLen = length(e);

figure(1)
clf
plot(e,ones(datLen),'o','MarkerSize',10,'LineWidth',2)
hold on
grid on
plot(e+a,zeros(datLen),'x','MarkerSize',10,'LineWidth',2)
for i = 1:datLen
    text(e(i)+a(i),-0.1,"#"+num2str(i)+": psi = "+num2str(psi(i)))
    text(e(i),1.1,"#"+num2str(i))
    plot([e(i),e(i)+a(i)],[1 0],'k')
end

ylim([-.5 1.5])
yticks([0 1])
yticklabels({'Equilibrium','Original ETA (e_i)'})

end

%%%%%%%

if run(2) == 1
outRaw = load("eHistory_similarity.mat");
out = outRaw.eHistory;
dataLen = length(out);
n = length(out{1});
psi = outRaw.psi;
data = zeros(dataLen,n);

for i = 1:dataLen
    data(i,:) = out{i};
end

cMap = jet(1000);
cList = zeros(n,3);
for i = 1:n
    idx = round((psi(i)-min(psi))/(max(psi)-min(psi))*1000);
    if idx == 0
        idx = 1;
    end
    cList(i,:) = cMap(idx,:);
end

figure(21)
clf
for i = 1:n
    plot(data(:,i),-(1:dataLen),'o:','Color',cList(i,:))
    hold on
    text(data(1,i),0.1,"#"+num2str(i))
end
grid on
colormap("jet")
cb = colorbar;
caxis([min(psi) max(psi)])
ylabel(cb,'urgency','FontSize',15)

end
