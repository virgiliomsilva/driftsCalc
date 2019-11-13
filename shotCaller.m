% caller
clear
clc

tic

noFloors = 10;
heightFloor = 28.5/noFloors;
IML = [.05, .1, .3, .5, .75, 1, 1.25, 1.5, 1.75, 2];
hazard_curve = importdata('hazardCurveLis.mat');

for i = 2%1 : 3%: 6
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
    
    ISDthreshold = disp80/(heightFloor * noFloors);
    [ISDmatrix, notConvergedRecords, IMLisd, PoE] = driftsExtract(dir, buildingName, code, noFloors, heightFloor, IML, ISDthreshold,'print','global');

    
    vul_coll_curve = PoE;
    rtP = 50;
    [aal_aapc] = aal_aapc_calc(hazard_curve,vul_coll_curve,rtP);
    save([buildingName '_' code '_aapc'],'aal_aapc');

    % plot 1 
    subplot(1,2,1)
    
    hold on
    scatter(ISDmatrix(:,1), ISDmatrix(:,3), 'b');
    scatter(IMLisd(:,1), IMLisd(:,2), 'filled','o r');
    xticks (IML);
    title([buildingName ' ' code]);
    xlabel('IML');
    ylabel('ISD');
    hold off
    
    % plot 2 
    subplot(1,2,2)
    X = PoE(:,1);
    Y = PoE(:,2);
    func = @(fit,xdata)logncdf(xdata,fit(1),fit(2));
    fit = lsqcurvefit(func,[0.8 0.4],X,Y);
    save([buildingName '_' code '_fit'],'fit');
%     figure();
    plot(linspace(min(X),max(X),100),logncdf(linspace(min(X),max(X),100),fit(1),fit(2)),'b');
    hold on
    plot(X,Y,'o','Color',[0.5 0.5 0.5]);
    hold off
        
    saveas(gcf,[buildingName '_' code '.png'])
    
    
    toc
end