% example caller
clear
clc
tic
buildingName = 'regular';
code = 'DC2' ; 
noFloors = 5;
height = 2.8;
IML = [.05, .1, .3, .5, .75, 1, 1.25, 1.5, 1.75, 2];
ISDthreshold = .32/14;%.25/14;   % .25/14; %0.0407535714285714;   %0.0067;
%%
[ISDmatrix, notConvergedRecords, IMLisd, PoE] = driftsExtract(buildingName, code, noFloors, height, IML, ISDthreshold,'print','global');

hazard_curve = importdata('hazardCurve.mat');
vul_coll_curve = PoE;
rtP = 50;

[aal_aapc] = aal_aapc_calc(hazard_curve,vul_coll_curve,rtP);
%%

X = PoE(:,1);
Y = PoE(:,2);
func = @(fit,xdata)logncdf(xdata,fit(1),fit(2));
fit = lsqcurvefit(func,[0.8 0.4],X,Y);
figure();
plot(linspace(min(X),max(X),100),logncdf(linspace(min(X),max(X),100),fit(1),fit(2)),'b');
hold on 
plot(X,Y,'o','Color',[0.5 0.5 0.5]);

save(['fit_' buildingName '_' code],'fit');
toc