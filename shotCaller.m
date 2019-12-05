% caller
clear
clc

tic
%%
noFloors = 10;
heightFloor = 28.5/noFloors;
IML = [.05, .1, .3, .5, .75, 1, 1.25, 1.5, 1.75, 2];
hazard_curve = importdata('hazardCurveLis.mat');

inc = max(IML)/length(IML);
aux1 = [inc:inc:max(IML)];

for i = 1:6
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
    X = PoE(:,1);
    Y = PoE(:,2);
    func = @(fit,xdata)logncdf(xdata,fit(1),fit(2));
    fit = lsqcurvefit(func,[0.8 0.4],X,Y);
    save([buildingName '_' code '_fit'],'fit');
    
    % average annual probability of collapse
    rtP = 50;
    frag_curve(:,1) = linspace(min(X),max(X),100);
    frag_curve(:,2) = logncdf(linspace(min(X),max(X),100),fit(1),fit(2));
    [aal_aapc] = aal_aapc_calc(hazard_curve,frag_curve,rtP);
    save([buildingName '_' code '_aapc'],'aal_aapc');
    
    %% PLOT
    % plot 1 
    subplot(1,2,1)
    
    [xDots, ~] = xInfo(ISDmatrix(:,1), IML);
    hold on
    scatter(xDots, ISDmatrix(:,3)*100, 'b');
    scatter(unique(xDots), IMLisd(:,2)*100, 'filled','o r');

    axis([0 2 0 5])
    xticks (aux1);
    xticklabels(num2cell(IML));
    
    %title([buildingName ' ' code]);
    xlabel('IML [m/s^2]','FontSize', 10, 'FontName', 'Arial','FontWeight','normal'); 
    ylabel('Global Drift [%]','FontSize', 10, 'FontName', 'Arial','FontWeight','normal');
    hold off 
        
    % plot 2 
    subplot(1,2,2)
    
    hold on
    plot(frag_curve(:,1), frag_curve(:,2));
    
    axis([0 2 0 1])
    xlabel('IML [m/s^2]','FontSize', 10, 'FontName', 'Arial','FontWeight','normal'); 
    ylabel('Average Annual Probability of Collapse','FontSize', 10, 'FontName', 'Arial','FontWeight','normal');

    % save png
    set(gcf, 'PaperUnits', 'centimeters');
    x_width=16 ;y_height=8;
    set(gcf, 'PaperPosition', [0 0 x_width y_height]); %
    saveas(gcf,[buildingName '_' code '.png'])
    
    clear xDots names ISDmatrix IMLisd 
    close(gcf)
    %%
    a = toc;
    mins = floor(a/60);
    secs = num2str(round(a - mins*60));
    mins = num2str(mins);
    disp(['Elapsed time: ' mins ' minutes and ' secs ' seconds'])
end
disp('Finished')