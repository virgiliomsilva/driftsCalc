%record 150
load('tenerIT_DC3_XX.mat');
XX = disp_x (:,[299 300],10);
load('tenerIT_DC3_YY.mat');
YY = disp_y (:,[299 300],10);
s1 = importdata('records_info\rec_150_dir1.txt');
s2 = importdata('records_info\rec_150_dir2.txt');

XX = XX(1:size(s1,1),:);
YY = YY(1:size(s2,1),:);
ZZ = [];
for i = 1: size(YY,1)
    ZZ(i,1) = XX(i,1);
    ZZ(i,2) = sqrt(XX(i,2)^2 + YY(i,2)^2);
    
end

hold on
plot(XX(:,1),XX(:,2),'Color','black','LineWidth',1)
title('Sinal em XX')
hold off
set(gcf, 'PaperUnits', 'centimeters');
x_width=12 ;y_height=8;
set(gcf, 'PaperPosition', [0 0 x_width y_height]); %
saveas(gcf,['XXgraph'  '.png'])
close(gcf)

hold on
plot(YY(:,1),YY(:,2),'Color','black','LineWidth',1)
title('Sinal em YY')
hold off
set(gcf, 'PaperUnits', 'centimeters');
x_width=12 ;y_height=8;
set(gcf, 'PaperPosition', [0 0 x_width y_height]); %
saveas(gcf,['YYgraph'  '.png'])
close(gcf)

hold on
plot(ZZ(:,1),ZZ(:,2),'Color','black','LineWidth',1)
title('Deslocamento da Cobertura')
hold off
set(gcf, 'PaperUnits', 'centimeters');
x_width=12 ;y_height=8;
set(gcf, 'PaperPosition', [0 0 x_width y_height]); %
saveas(gcf,['ZZgraph'  '.png'])
close(gcf)