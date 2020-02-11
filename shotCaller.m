% caller
clear
clc
%%
noFloors = 10;
heightFloor = 28.5/noFloors;
IML = [.05, .1, .3, .5, .75, 1, 1.25, 1.5, 1.75, 2];
hazard_curve = importdata('hazardCurveLis.mat');

%%
tic
inc = max(IML)/length(IML);
aux1 = [inc:inc:max(IML)];

for i = 6
    switch i
        case 1
            disp80 = 0.75;
            buildingName = 'tenerPT' ;
            code = 'DC1' ;
            dir = ['D:\Google Drive\Disco UPorto\MIECIVIL\5 Ano\2 Semestre\Models\tener\Portugal\ite2\' code '\seismoStruct\DTHA_results'];
            
        case 2
            disp80 = 1.15;
            buildingName = 'tenerPT' ;
            code = 'DC2' ;
            dir = ['D:\Google Drive\Disco UPorto\MIECIVIL\5 Ano\2 Semestre\Models\tener\Portugal\ite2\' code '\seismoStruct\DTHA_results'];
            
        case 3
            disp80 = 1.19;
            buildingName = 'tenerPT' ;
            code = 'DC3' ;
            dir = ['D:\Google Drive\Disco UPorto\MIECIVIL\5 Ano\2 Semestre\Models\tener\Portugal\ite2\' code '\seismoStruct\DTHA_results'];
            
        case 4
            disp80 = 0.54;
            buildingName = 'tenerIT' ;
            code = 'DC1' ;
            dir = ['D:\Google Drive\Disco UPorto\MIECIVIL\5 Ano\2 Semestre\Models\tener\Italy\ite1\' code '\seismoStruct\DTHA_results'];
            
        case 5
            disp80 = 0.63;
            buildingName = 'tenerIT' ;
            code = 'DC2' ;
            dir = ['D:\Google Drive\Disco UPorto\MIECIVIL\5 Ano\2 Semestre\Models\tener\Italy\ite1\' code '\seismoStruct\DTHA_results'];
            
        case 6
            disp80 = 1.00;
            buildingName = 'tenerIT' ;
            code = 'DC3' ;
            dir = ['D:\Google Drive\Disco UPorto\MIECIVIL\5 Ano\2 Semestre\Models\tener\Italy\ite1\' code '\seismoStruct\DTHA_results'];
    end
    
    disp(['Currently executing ' buildingName ' ' code])
    disp('...')
    
    %
    ISDthreshold = disp80/(heightFloor * noFloors);
    [ISDmatrix, notConvergedRecords, IMLisd, PoE] = driftsExtract(dir, buildingName, code, noFloors, heightFloor, IML, ISDthreshold,'print','global');
    
    % discrete fragility curve TO continuous function
    if (strcmp(buildingName,'tenerIT') && strcmp(code, 'DC3'))
        PoE(3,:) = [];
    end
    X = PoE(:,1);
    Y = PoE(:,2);
    
    func = @(fit,xdata)logncdf(xdata,fit(1),fit(2));
    fit = lsqcurvefit(func,[0.8 0.4],X,Y);
    save(['figs\\' buildingName '_' code '_fit'],'fit');
    
    % average annual probability of collapse
    rtP = 50;
    frag_curve(:,1) = linspace(min(X),max(X),100);
    frag_curve(:,2) = logncdf(linspace(min(X),max(X),100),fit(1),fit(2));
    [aal_aapc] = aal_aapc_calc(hazard_curve,frag_curve,rtP);
%     display(aal_aapc)
    save(['figs\\' buildingName '_' code '_aapc'],'aal_aapc');
    csvwrite(['figs\\' buildingName '_' code '_aapc.csv'],aal_aapc);
    save(['figs\\' buildingName '_' code '_frag_curve'],'frag_curve');
    
    % PLOT
    % plot 1
    figure
    
        % title
    str{1} = ['\bf ', code, ' \rm'];
    annotation('textbox', [0 0.9 1 0.1], ...
    'String', str, ...
    'EdgeColor', 'none', ...
    'HorizontalAlignment', 'center')
    
    
    subplot(1,2,1)
    
    hold on
    [xDots, ~] = xInfo(ISDmatrix(:,1), IML);
    scatter(xDots, ISDmatrix(:,3)*100, 'k');
    scatter(unique(xDots), IMLisd(:,2)*100, 'filled','o r');
    
    axis([0 2 0 5])
    xticks (aux1);
    xticklabels(num2cell(IML));
    xtl = get(gca,'XTickLabel');
    set(gca,'XTickLabel', xtl,'fontsize',8);%,'FontWeight','bold')
    
    xlabel('SA [g]','FontSize', 10, 'FontName', 'Arial','FontWeight','normal');
    ylabel('Global Drift [%]','FontSize', 10, 'FontName', 'Arial','FontWeight','normal');
    
    line([0 2], [ISDthreshold*100 ISDthreshold*100],'Color','red','LineWidth',1)
    
    hold off
    
    % plot 2
    subplot(1,2,2)
    
    hold on
    plot(frag_curve(:,1), frag_curve(:,2),'LineWidth', 1, 'Color', 'k');
%     plot(PoE(:,1), PoE(:,2))
    
    axis([0 2 0 1])
    xlabel('SA [g]','FontSize', 10, 'FontName', 'Arial','FontWeight','normal');
    ylabel('Probability of Exceedance','FontSize', 10, 'FontName', 'Arial','FontWeight','normal');
    hold off
    
    % save png
    set(gcf, 'PaperUnits', 'centimeters');
    x_width=15 ;y_height= x_width/2;
    set(gcf, 'PaperPosition', [0 0 x_width y_height]); %
    saveas(gcf,['figs\\' buildingName '_' code '.png'])
    
    clear xDots names ISDmatrix IMLisd
    close(gcf)
end

%%
for i = 1:2
    switch i
        case 1
            outName = 'tenerPT';
            DC1 = importdata('D:\Google Drive\Disco UPorto\MIECIVIL\5 Ano\2 Semestre\DocDissertação\figures\driftsCalc\figs\tenerPT_DC1_frag_curve.mat');
            DC2 = importdata('D:\Google Drive\Disco UPorto\MIECIVIL\5 Ano\2 Semestre\DocDissertação\figures\driftsCalc\figs\tenerPT_DC2_frag_curve.mat');
            DC3 = importdata('D:\Google Drive\Disco UPorto\MIECIVIL\5 Ano\2 Semestre\DocDissertação\figures\driftsCalc\figs\tenerPT_DC3_frag_curve.mat');
            
        case 2
            outName = 'tenerIT';
            DC1 = importdata('D:\Google Drive\Disco UPorto\MIECIVIL\5 Ano\2 Semestre\DocDissertação\figures\driftsCalc\figs\tenerIT_DC1_frag_curve.mat');
            DC2 = importdata('D:\Google Drive\Disco UPorto\MIECIVIL\5 Ano\2 Semestre\DocDissertação\figures\driftsCalc\figs\tenerIT_DC2_frag_curve.mat');
            DC3 = importdata('D:\Google Drive\Disco UPorto\MIECIVIL\5 Ano\2 Semestre\DocDissertação\figures\driftsCalc\figs\tenerIT_DC3_frag_curve.mat');
            
    end
    
    hold on
    a1 = plot(DC1(:,1), DC1(:,2),'LineWidth', 1, 'Color',[0.0000 0.4470 0.7410]);
    a2 = plot(DC2(:,1), DC2(:,2),'LineWidth', 1, 'Color',[0.8500 0.3250 0.0980]);
    a3 = plot(DC3(:,1), DC3(:,2),'LineWidth', 1, 'Color',[0.9290 0.6940 0.1250]);
    
    axis([0 2 0 1])
    xlabel('SA [g]','FontSize', 10, 'FontName', 'Arial','FontWeight','normal');
    ylabel('Probability of Exceedance','FontSize', 10, 'FontName', 'Arial','FontWeight','normal');
    
    legend([a1 a2 a3], {'DC1','DC2','DC3'}, ...
    'Location','east', 'color','none', 'Box', 'off');%, 'NumColumns', 4);%,'orientation','horizontal');
    hold off
    
    % save png
    set(gcf, 'PaperUnits', 'centimeters');
    x_width=10 ;y_height= x_width * .8;
    set(gcf, 'PaperPosition', [0 0 x_width y_height]); %
    saveas(gcf,['figs\\' outName '_fragCurve.png'])
    close(gcf)
    
end

disp('Finished')
toc