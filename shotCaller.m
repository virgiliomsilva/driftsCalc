% caller
clear
clc

tic
%%
XX = [0.2:0.2:2];
xizes = [];
for i = XX
    count = 0;
    while count < 20
        xizes(end+1) = i;.
        count = count + 1;
    end
end
%%
noFloors = 10;
heightFloor = 28.5/noFloors;
IML = [.05, .1, .3, .5, .75, 1, 1.25, 1.5, 1.75, 2];
hazard_curve = importdata('hazardCurveLis.mat');

% os valores
% records que não convergeram estão a entrar na mesma mas fora do isd
% threshhold refer to approppriate section

for i = 71 
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

    % discrete fragility curve TO continuous function  
    X = PoE(:,1);
    Y = PoE(:,2);
    func = @(fit,xdata)logncdf(xdata,fit(1),fit(2));
    fit = lsqcurvefit(func,[0.8 0.4],X,Y);
%     save([buildingName '_' code '_fit'],'fit');
    
    % average annual probability of collapse
    rtP = 50;
    frag_curve(:,1) = linspace(min(X),max(X),100);
    frag_curve(:,2) = logncdf(linspace(min(X),max(X),100),fit(1),fit(2));
    [aal_aapc] = aal_aapc_calc(hazard_curve,frag_curve,rtP);
%     save([buildingName '_' code '_aapc'],'aal_aapc');
    
    
    % plot 1 
%     subplot(1,2,1)
    
    hold on
    axis([0 2 0 15])
%     scatter(ISDmatrix(:,1), ISDmatrix(:,3)*100, 'b');
%     scatter(IMLisd(:,1), IMLisd(:,2)*100, 'filled','o r');
    scatter(xizes, ISDmatrix(:,3)*100, 'b');
    scatter(XX, IMLisd(:,2)*100, 'filled','o r');
    xticks (XX);
    xticklabels(num2cell(IML));
    
    title([buildingName ' ' code]);
    xlabel('IML'); 
    ylabel('Global Drift [%]');
    hold off
    
    % plot 2 
    subplot(1,2,2)
    plot(frag_curve(:,1), frag_curve(:,2));
%     X = PoE(:,1);
%     Y = PoE(:,2);
%     func = @(fit,xdata)logncdf(xdata,fit(1),fit(2));
%     fit = lsqcurvefit(func,[0.8 0.4],X,Y);
%     save([buildingName '_' code '_fit'],'fit');
%     figure();
%     plot(linspace(min(X),max(X),100),logncdf(linspace(min(X),max(X),100),fit(1),fit(2)),'b');
%     hold on
%     plot(X,Y,'o','Color',[0.5 0.5 0.5]);
%     hold off
%     
%     clear vul_coll_curve
%     vul_coll_curve(:,1) = linspace(min(X),max(X),100);
%     vul_coll_curve(:,2) = logncdf(linspace(min(X),max(X),100),fit(1),fit(2));
%     [aal_aapc] = aal_aapc_calc(hazard_curve,vul_coll_curve,rtP);
%     save([buildingName '_' code '_aapc'],'aal_aapc');
     
     
%     saveas(gcf,[buildingName '_' code '.png'])
    
%     clear
       
    toc
end